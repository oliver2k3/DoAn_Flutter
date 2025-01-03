package com.nhom7.qltd.dto;

import lombok.Data;

import java.io.Serializable;

@Data
public class ListContractDto implements Serializable {
    private int id;
    private String name;
    private String loanname;
    private float interestRate;
    private int loanTerm;
    private float totalPayment;
    private float totalInterest;
    private float paid;
    private float remaining;
    private  String Status;
    private double amount;


    public ListContractDto(int id, String name, String name1, float interestRate, int loanTerm, float totalPayment, float totalInterest, float paid, float remaining, float loanAmount, String name2) {
        this.id = id;
        this.name = name;
        this.loanname = name1;
        this.interestRate = interestRate;
        this.loanTerm = loanTerm;
        this.totalPayment = totalPayment;
        this.totalInterest = totalInterest;
        this.paid = paid;
        this.remaining = remaining;
        this.amount = loanAmount;
        this.Status = name2;
    }
}
