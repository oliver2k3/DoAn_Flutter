package com.nhom7.qltd.model;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;
@Data
@Entity
@Table(name = "saving")

public class SavingEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "saving_id")
    private Integer id;
    @Column(name = "email")
    private String email;
    @Column(name = "amount")
    private Double amount;
    @Column(name = "created_date")
    private LocalDateTime createdDate;
    @Column(name = "maturity_date")
    private LocalDateTime maturityDate;
    @Column(name = "deposit_duration")
    private Integer depositDuration;
    @Column(name = "interest_rate")
    private Double interestRate;
    @Column(name = "status")
    private String status;
    @Column(name ="deposit_amount")
    private Double depositAmount;
    @Column(name ="total_amount")
    private Double totalAmount;

    public SavingEntity() {
        // No-arg constructor
    }

    public SavingEntity(Integer id, Double amount, Integer depositDuration, Double interestRate, String email, LocalDateTime createdDate, LocalDateTime maturityDate, String status, Double depositAmount, Double totalAmount) {
        this.id = id;
        this.email = email;
        this.amount = amount;
        this.createdDate = createdDate;
        this.maturityDate = maturityDate;
        this.depositDuration = depositDuration;
        this.interestRate = interestRate;
        this.status = status;
        this.depositAmount = depositAmount;
        this.totalAmount = totalAmount;
    }


    // Getters and Setters
}