package com.nhom7.qltd.dao;

import com.nhom7.qltd.model.LoanEntity;
import org.springframework.data.repository.CrudRepository;

public interface LoanDao extends CrudRepository<LoanEntity, Integer> {

}
