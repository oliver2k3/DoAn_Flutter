package com.nhom7.qltd.service;

import com.nhom7.qltd.dao.TransitionDao;
import com.nhom7.qltd.dao.UserDao;
import com.nhom7.qltd.dto.TransitionDto;
import com.nhom7.qltd.model.TransitionEntity;
import com.nhom7.qltd.model.UserEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class TransitionService {
    private final TransitionDao transitionDao;
    private final UserDao userDao;
    private final UsersService userService;

    public void performTransfer(TransitionDto transitionDto) {
        UserEntity sender = userDao.findByCardNumber(transitionDto.getSender()).orElseThrow(
                () -> new IllegalArgumentException("Sender not found")
        );
        UserEntity receiver = userDao.findByCardNumberAndBank(transitionDto.getReceiver(),transitionDto.getReceiveBank()).orElseThrow(
                () -> new IllegalArgumentException("Receiver not found")
        );

        if (sender.getEmail().equals(receiver.getEmail())) {
            throw new IllegalArgumentException("Sender and receiver cannot be the same");
        }

        if (transitionDto.getAmount() <= 0) {
            throw new IllegalArgumentException("Amount must be greater than 0");
        }

        if (sender.getBalance() < transitionDto.getAmount()) {
            throw new IllegalArgumentException("Insufficient balance");
        }

        sender.setBalance(sender.getBalance() - transitionDto.getAmount());
        receiver.setBalance(receiver.getBalance() + transitionDto.getAmount());

        userDao.save(sender);
        userDao.save(receiver);

        TransitionEntity transitionEntity = new TransitionEntity();
        transitionEntity.setFromUser(sender.getCardNumber());
        transitionEntity.setToUser(receiver.getCardNumber());
        transitionEntity.setAmount(transitionDto.getAmount());
        transitionEntity.setSenderBank(sender.getBank());
        transitionEntity.setReceiverBank(receiver.getBank());
        transitionEntity.setSenderName(sender.getName());
        transitionEntity.setReceiverName(receiver.getName());
        transitionEntity.setFee(0.0);
        transitionEntity.setMessage(transitionDto.getMessage());
        transitionEntity.setCreated(LocalDateTime.now());

        transitionDao.save(transitionEntity);
    }

    public List<TransitionEntity> getMyTransition(String token) {
        String myCardNumber = userService.getCardNumberfromToken(token);
        return transitionDao.findByFromUser(myCardNumber).stream().sorted(
                (t1, t2) -> t2.getCreated().compareTo(t1.getCreated())
        ).toList();
    }
    public List<TransitionEntity> getReceivedTransitions(String token) {
        String myCardNumber = userService.getCardNumberfromToken(token);
        return transitionDao.findByToUser(myCardNumber).stream().sorted(
                (t1, t2) -> t2.getCreated().compareTo(t1.getCreated())
        ).toList();
    }
}
