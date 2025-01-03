package com.nhom7.qltd.dto;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;

@Data
public class RequestDepositDto  implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;
    String requesterEmail;
    String receiver;
    String receiveBank;
    double amount;
    String message;

}
