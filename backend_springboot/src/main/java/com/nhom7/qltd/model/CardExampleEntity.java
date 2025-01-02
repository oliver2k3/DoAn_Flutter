package com.nhom7.qltd.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@Table(name = "card_example")
public class CardExampleEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;
    @Column(name = "name")
    private String name;
    @Column(name = "bank_name")
    private String bankName;
    @Column(name = "card_number")
    private String cardNumber;
    @Column(name = "balance")
    private double balance;
    @Column(name = "expired_date")
    private String expiredDate;
    @Column(name = "ccv")
    private String ccv;
}
