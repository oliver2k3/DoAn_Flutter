package com.nhom7.qltd.model;

import jakarta.persistence.*;
import lombok.Data;
@Entity
@Data
@Table (name = "card")

public class CardEntity {
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
    @ManyToOne
    @JoinColumn(name = "User_ID", referencedColumnName = "user_id")
    private UserEntity user;
}
