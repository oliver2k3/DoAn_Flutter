package com.nhom7.qltd.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "transition")
@Data
@NoArgsConstructor
public class TransitionEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "transition_id")
    private Integer id;

    @Column(name = "from_user")
    private String fromUser;

    @Column(name = "to_user")
    private String toUser;

    @Column(name = "amount")
    private Double amount;

    @Column(name = "fee")
    private Double fee;

    @Column(name = "created_at")
    private LocalDateTime created;

    @Column(name = "message")
    private String message;
    @Column(name = "sender_bank")
    private String senderBank;
    @Column(name = "receiver_bank")
    private String receiverBank;
    @Column(name = "sender_name")
    private String senderName;
    @Column(name = "receiver_name")
    private String receiverName;
}
