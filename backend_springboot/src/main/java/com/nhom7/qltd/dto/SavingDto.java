package com.nhom7.qltd.dto;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;

@Data
public class SavingDto implements Serializable {
    @Serial
    private static final long serialVersionUID = 1L;
    private  String email;
    private double amount;
    private  int depositDuration;
    private double interestRate;

}
