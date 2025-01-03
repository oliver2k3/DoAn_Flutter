package com.nhom7.qltd.dao;

import com.nhom7.qltd.model.DepositRequestEntity;
import com.nhom7.qltd.model.UserEntity;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface DepositRequestDao extends CrudRepository<DepositRequestEntity, Integer> {
    List<DepositRequestEntity> findByRequester(UserEntity requester);
    List<DepositRequestEntity> findByReceiver(UserEntity receiver);
}
