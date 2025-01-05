package com.nhom7.qltd.dao;


import com.nhom7.qltd.model.LoanContractEntity;
import com.nhom7.qltd.model.LoanEntity;
import com.nhom7.qltd.model.UserEntity;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface LoanContractDAO extends CrudRepository<LoanContractEntity, Integer> {
    List<LoanContractEntity> findByUser(UserEntity user);
}
