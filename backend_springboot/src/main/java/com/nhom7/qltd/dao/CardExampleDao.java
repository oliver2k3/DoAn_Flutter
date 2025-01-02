package com.nhom7.qltd.dao;

import com.nhom7.qltd.model.CardExampleEntity;
import org.springframework.data.repository.CrudRepository;

import java.util.List;
import java.util.Optional;

public interface CardExampleDao extends CrudRepository<CardExampleEntity, Integer> {
    List<CardExampleEntity> findAll();

    Optional<CardExampleEntity> findById(int id);

    Optional<CardExampleEntity> findByCardNumber(String cardNumber);
}
