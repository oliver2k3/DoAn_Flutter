package com.nhom7.qltd.service;

import com.nhom7.qltd.dao.CardDao;
import com.nhom7.qltd.dao.CardExampleDao;
import com.nhom7.qltd.dao.UserDao;
import com.nhom7.qltd.dto.AddCardDto;
import com.nhom7.qltd.dto.DepositDto;
import com.nhom7.qltd.model.CardEntity;
import com.nhom7.qltd.model.CardExampleEntity;
import com.nhom7.qltd.model.UserEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CardService {
    private final CardDao cardDao;
    private final CardExampleDao cardExampleDao;
    private final UserDao UserDao;
    public String addCardToUser(AddCardDto addCardDTO, UserEntity user) {
        // Check if the user already has a card with the same card number and bank name
        Optional<CardEntity> existingUserCard = cardDao.findByCardNumberAndBankNameAndUser(addCardDTO.getCardNumber(), addCardDTO.getBankName(), user);
        if (existingUserCard.isPresent()) {
            return "User already has a card with the same card number and bank name";

            // User already has a card with the same card number and bank name
        }

        // Check if the card exists in the card example database
        Optional<CardExampleEntity> existingCard = cardExampleDao.findByCardNumber(addCardDTO.getCardNumber());
        if (existingCard.isPresent() &&
                existingCard.get().getName().equals(addCardDTO.getName()) &&
                existingCard.get().getBankName().equals(addCardDTO.getBankName()) &&
                existingCard.get().getExpiredDate().equals(addCardDTO.getExpiredDate()) &&
                existingCard.get().getCcv().equals(addCardDTO.getCcv())) {

            CardEntity newCard = new CardEntity();
            newCard.setName(existingCard.get().getName());
            newCard.setBankName(existingCard.get().getBankName());
            newCard.setCardNumber(existingCard.get().getCardNumber());
            newCard.setExpiredDate(existingCard.get().getExpiredDate());
            newCard.setBalance(existingCard.get().getBalance());
            newCard.setUser(user);
            cardDao.save(newCard);
            return "Success"; // Card added successfully
        }
        return "Card does not match existing records"; // Card does not match
    }

    public List<CardEntity> getCardsOfUser(UserEntity user) {
        return cardDao.findByUser(user);
    }
    public String depositToAccount(DepositDto depositDto, UserEntity user) {
        Optional<CardEntity> cardEntityOptional = cardDao.findByCardNumberAndUser(depositDto.getCardNumber(), user);
        if (cardEntityOptional.isPresent()) {
            CardEntity cardEntity = cardEntityOptional.get();
            cardEntity.setBalance(cardEntity.getBalance() - depositDto.getAmount());
            cardDao.save(cardEntity);
            // Assuming there is a method to update the user's account balance
            user.setBalance(user.getBalance() + depositDto.getAmount());
            UserDao.save(user);
            return "Deposit successful";
        } else {
            return "Card not found";
        }
    }
}