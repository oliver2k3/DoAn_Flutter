package com.backend_springboot.model;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Entity
@Table(name = "LoanContract")
@Data
public class LoanContractEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ID")
    private int id;
    @ManyToOne
    @JoinColumn(name = "User_ID", referencedColumnName = "user_id")
    private UserEntity user;
    @ManyToOne
    @JoinColumn(name = "LOAN_ID", referencedColumnName = "ID")
    private LoanEntity loan;
    @ManyToOne
    @JoinColumn(name = "status_id", referencedColumnName = "ID")
    private StatusEntity status;

    @Column(name = "LoanAmount")
    private float loanAmount;
    @Column(name = "InterestRate")
    private float interestRate;
    @Column(name = "LoanTerm", nullable = false)
    private int loanTerm;
    @Column(name = "EMI")
    private float emi;
    @Column(name = "TotalPayment")
    private float totalPayment;
    @Column(name = "TotalInterest")
    private float totalInterest;
    @Column(name = "Paid")
    private float paid;
    @Column(name = "Remaining")
    private float remaining;
    @Column(name = "LastPayment")
    private LocalDateTime lastPayment;
    @Column(name = "NextPayment")
    private LocalDateTime nextPayment;
    @Column(name = "ExpirationDate")
    private LocalDateTime expirationDate;
    @Column(name = "thisMonthAmount")
    private float thisMonthAmount; ;
    @Column(name = "created_date")
    private LocalDateTime createdDate;
}
