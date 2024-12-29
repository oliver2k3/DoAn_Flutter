package com.backend_sprringboot.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Entity
@Table(name = "loan")
@Data
public class LoanEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ID")
    private int id;

    @Column(name = "name", nullable = false)
    @NotBlank(message = "Vui lòng nhập tên gói vay")
    private String name;
    @Column(name = "BaseInterestRate", nullable = false)
    private float baseInterestRate;
    @Column(name = "InterestRate2")
    private float interestRate2;
    @Column(name = "InterestRate3")
    private float interestRate3;
    @Column(name = "description1", nullable = false)
    private String description1;
    @Column(name = "description2")
    private String description2;
    @Column(name = "description3")
    private String description3;

}
