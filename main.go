package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	_ "github.com/lib/pq"

	"github.com/nats-io/nats.go"
	"github.com/nats-io/stan.go"
)

var (
	U     stan.Conn
	cache = make(map[string]Order)
)

func main() {
	var db, err = sql.Open("postgres",
		fmt.Sprintf("host=%s port=%d sslmode=%s dbname=%s user=%s password=%s",
			"localhost", 54321, "disable", "postgres", "postgres", "admin"))
	if err != nil {
		fmt.Println(err)
		return
	}
	orders, err := getOrders(db)
	if err != nil {
		fmt.Println("Ошибка чтения Orders")
		return
	}
	for _, order := range orders {
		cache[order.OrderUid] = order
	}

	U, _ = stan.Connect("test-cluster", "client-1", stan.NatsURL(nats.DefaultURL))
	defer U.Close()

	sub, er := U.Subscribe("test-channel", func(m *stan.Msg) {
		fmt.Printf("Received a message: %s\n", string(m.Data))

		var order Order
		if err := json.Unmarshal(m.Data, &order); err != nil {
			fmt.Println(err)
			return
		}

		err = createOrder(db, order) //сохранение в postgres
		if err != nil {
			fmt.Println(err)
			return
		}
		cache[order.OrderUid] = order //сохранение в кэше

	}, stan.DurableName("my-durable-name"))

	if er != nil {
		log.Fatalln(er, "conn")
	}
	defer sub.Unsubscribe()
	/*U.Subscribe("foo", func(m *stan.Msg) {
		fmt.Printf("Received a message: %s\n", string(m.Data))
	})
	err = U.Publish("foo", []byte("Hello World third"))
	if err != nil {
		log.Fatalln(err, "publish")
	}
	*/
	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.HandleFunc("/getorder", getOrderHandler)
	r.HandleFunc("/createorder", createOrderHandler)
	r.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "index.html")
	})

	r.HandleFunc("/send", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "send.html")
	})

	go func() {
		if err := http.ListenAndServe(":3000", r); err != nil {
			panic(err)

		}
	}()
	select {}
}
