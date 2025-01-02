package com.nhom7.qltd.model;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "users")
@Data
public class UserEntity {

    /* Id of user */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private Integer id;

    /* Username of user */
    @Column(name = "username")
    private String name;

    /* Email of user */
    @Column(name = "email")
    private String email;

    /* Balance of user */
    @Column(name = "balance")
    private Double balance;

    /* Card number of user */
    @Column(name = "card_number")
    private String cardNumber;

    /* Bank of user */
    @Column(name = "bank")
    private String bank;

    /* Password of user */
    @Column(name = "hashed_password")
    private String password;

    /* Creation time */
    @Column(name = "created_at")
    private LocalDateTime created;

    /* Update time */
    @Column(name = "updated_at")
    private LocalDateTime updated;
    @Column(name = "address")
    private String address;
    @Column(name = "phone")
    private String phone;
    @Column(name = "CCCD_number")
    private String CCCD;


}
