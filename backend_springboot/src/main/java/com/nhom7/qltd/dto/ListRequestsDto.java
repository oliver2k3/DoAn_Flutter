package com.nhom7.qltd.dto;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.time.LocalDateTime;

@Data
public class ListRequestsDto implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;
    private int id;
    private String sender;
    private String receiver;
    private int statusId;
    private Double amount;
    private String message;
    private LocalDateTime createdDate;
    private LocalDateTime approvedDate;
    private String status;
    private String senderCardNumber;
    private String receiverCardNumber;
    public ListRequestsDto(int id, String sender, String receiver, int id1, double amount, String message, LocalDateTime createdDate, LocalDateTime approvedDate, String status, String senderCardNumber, String receiverCardNumber) {
        this.id = id;
        this.sender = sender;
        this.receiver = receiver;
        this.statusId = id1;
        this.amount = amount;
        this.message = message;
        this.createdDate = createdDate;
        this.approvedDate = approvedDate;
        this.status = status;
        this.senderCardNumber = senderCardNumber;
        this.receiverCardNumber = receiverCardNumber;
    }


}
