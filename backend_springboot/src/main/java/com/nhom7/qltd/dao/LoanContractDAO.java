package com.nhom7.qltd.dao;


import com.nhom7.qltd.model.LoanContractEntity;
import org.springframework.data.repository.CrudRepository;

public interface LoanContractDAO extends CrudRepository<LoanContractEntity, Integer> {
}
