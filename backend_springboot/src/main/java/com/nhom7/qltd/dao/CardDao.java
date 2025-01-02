package com.nhom7.qltd.dao;

import com.nhom7.qltd.model.CardEntity;
import com.nhom7.qltd.model.UserEntity;
import org.springframework.data.repository.CrudRepository;

import java.util.List;
import java.util.Optional;

public interface CardDao extends CrudRepository < CardEntity, Integer> {
    List<CardEntity> findAll();

    Optional<CardEntity> findById(int id);
    Optional<CardEntity> findByCardNumberAndBankNameAndUser(String cardNumber, String bankName, UserEntity user);
    List<CardEntity> findByUser(UserEntity user);
    Optional<CardEntity> findByCardNumber(String cardNumber);

    Optional<CardEntity> findByCardNumberAndUser(String cardNumber, UserEntity user);
}
