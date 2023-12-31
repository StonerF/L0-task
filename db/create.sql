CREATE TABLE orders
(
    order_uid          varchar      NOT NULL,
    track_number       varchar      NOT NULL,
    entry              varchar      NOT NULL,
    locale             varchar      NOT NULL,
    internal_signature varchar      NOT NULL,
    customer_id        varchar      NOT NULL,
    delivery_service   varchar      NOT NULL,
    shardkey           varchar      NOT NULL,
    sm_id              int4         NOT NULL,
    date_created       varchar      NOT NULL,
    oof_shard          varchar      NOT NULL,
    CONSTRAINT ordering_orders_pkey PRIMARY KEY (order_uid)
);

CREATE TABLE delivery
(
    id       int4    NOT NULL GENERATED BY DEFAULT AS IDENTITY ( INCREMENT 1),
    name     varchar NOT NULL,
    phone    varchar NOT NULL,
    zip      varchar NOT NULL,
    city     varchar NOT NULL,
    address  varchar NOT NULL,
    region   varchar NOT NULL,
    email    varchar NOT NULL,
    order_id varchar NOT NULL,
    CONSTRAINT ordering_delivery_pkey PRIMARY KEY (id),
    CONSTRAINT delivery_01t_fkey FOREIGN KEY (order_id)
        REFERENCES orders (order_uid) ON DELETE RESTRICT ON UPDATE RESTRICT

);

CREATE TABLE payment
(
    id            int4    NOT NULL GENERATED BY DEFAULT AS IDENTITY ( INCREMENT 1),
    transaction   varchar NOT NULL,
    request_id    varchar   NOT NULL,
    currency      varchar NOT NULL,
    provider      varchar NOT NULL,
    amount        int4    NOT NULL,
    payment_dt    int4    NOT NULL,
    bank          varchar NOT NULL,
    delivery_cost int4    NOT NULL,
    goods_total   int4    NOT NULL,
    custom_fee    int4    NOT NULL,
    order_id      varchar NOT NULL,
    CONSTRAINT ordering_payment_pkey PRIMARY KEY (id),
    CONSTRAINT payment_02t_fkey FOREIGN KEY (order_id)
        REFERENCES orders (order_uid) ON DELETE RESTRICT ON UPDATE RESTRICT
);

CREATE TABLE items
(
    id           int4    NOT NULL GENERATED BY DEFAULT AS IDENTITY ( INCREMENT 1),
    chrt_id      int4    NOT NULL,
    track_number varchar NOT NULL,
    price        numeric NOT NULL,
    rid          varchar NOT NULL,
    name         varchar NOT NULL,
    sale         int4    NOT NULL,
    size         varchar NOT NULL,
    total_price  numeric NOT NULL,
    nm_id        int4    NOT NULL,
    brand        varchar NOT NULL,
    status       int4    NOT NULL,
    order_id     varchar NOT NULL,
    CONSTRAINT ordering_items_pkey PRIMARY KEY (id),
    CONSTRAINT items_03t_fkey FOREIGN KEY (order_id)
        REFERENCES orders (order_uid) ON DELETE RESTRICT ON UPDATE RESTRICT
);