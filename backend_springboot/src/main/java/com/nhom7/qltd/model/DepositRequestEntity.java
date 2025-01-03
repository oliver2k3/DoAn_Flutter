package com.nhom7.qltd.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "deposit_request")
@Data
public class DepositRequestEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne
    @JoinColumn(name = "requester_id", nullable = false)
    private UserEntity requester;

    @ManyToOne
    @JoinColumn(name = "receiver_id", nullable = false)
    private UserEntity receiver;

    private double amount;
    @ManyToOne
    @JoinColumn(name = "status_id", referencedColumnName = "ID")
    private StatusEntity status;
    private LocalDateTime createdDate;
    private LocalDateTime approvedDate;
    private String message;
}