package com.backend_springboot.dao;


import com.backend_springboot.model.LoanContractEntity;
import org.springframework.data.repository.CrudRepository;

public interface LoanContractDao extends CrudRepository<LoanContractEntity, Integer> {
}
