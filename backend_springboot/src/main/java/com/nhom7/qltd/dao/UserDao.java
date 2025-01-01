package com.nhom7.qltd.dao;

import com.nhom7.qltd.model.UserEntity;
import org.springframework.data.repository.CrudRepository;

import java.util.Optional;

public interface UserDao extends CrudRepository<UserEntity, Integer> {
    Optional<UserEntity> findByEmail(String email);
    Optional<UserEntity> findByCardNumber(String cardNumber);
}
