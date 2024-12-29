package com.backend_sprringboot.model;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "users")
@Data
public class UserEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private Integer id;

    @Column(name = "username")
    private String name;

    @Column(name = "email")
    private String email;

    @Column(name = "balance")
    private Double balance;

    @Column(name = "card_number")
    private String cardNumber;

    @Column(name = "bank")
    private String bank;

    @Column(name = "hashed_password")
    private String password;

    @Column(name = "created_at")
    private LocalDateTime created;

    @Column(name = "updated_at")
    private LocalDateTime updated;
    @Column(name = "address")
    private String address;
    @Column(name = "phone")
    private String phone;
    @Column(name = "CCCD_number")
    private String CCCD;
    @OneToMany(mappedBy = "user")
    private List<LoanContractEntity> loanContract;
}
