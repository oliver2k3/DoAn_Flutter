package com.nhom7.qltd.dto;

import lombok.Data;

import java.io.Serializable;

@Data
public class CardInfoDto implements Serializable
{
    private static final long serialVersionUID = 1L;
    private String cardNumber;
    private String bankName;
    private String expiredDate;
    private String name;
    private  double balance;
    public CardInfoDto(String cardNumber, String bankName, String expiredDate,  String name, double balance) {
        this.cardNumber = cardNumber;
        this.bankName = bankName;
        this.expiredDate = expiredDate;
        this.name = name;
        this.balance = balance;
    }
}
