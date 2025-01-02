package com.nhom7.qltd.dto;

import lombok.Data;

import java.io.Serializable;

@Data
public class DepositDto implements Serializable {
    private static final long serialVersionUID = 1L;
    private String cardNumber;
    private double amount;
}