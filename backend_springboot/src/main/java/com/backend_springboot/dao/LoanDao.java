package com.backend_springboot.dao;

import com.backend_springboot.model.LoanEntity;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface  LoanDao  extends CrudRepository<LoanEntity, Integer> {
    List<LoanEntity> findAll();
}
