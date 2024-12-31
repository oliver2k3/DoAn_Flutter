package com.backend_springboot.service;

import com.backend_springboot.dao.TransitionDao;
import com.backend_springboot.dao.UserDao;
import com.backend_springboot.dto.TransitionDto;
import com.backend_springboot.model.TransitionEntity;
import com.backend_springboot.model.UserEntity;
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
        UserEntity receiver = userDao.findByCardNumber(transitionDto.getReceiver()).orElseThrow(
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
        transitionEntity.setFee(0.0);
        transitionEntity.setCreated(LocalDateTime.now());

        transitionDao.save(transitionEntity);
    }

    public List<TransitionEntity> getMyTransition(String token) {
        String myCardNumber = userService.getCardNumberfromToken(token);
        return transitionDao.findByFromUser(myCardNumber).stream().sorted(
                (t1, t2) -> t2.getCreated().compareTo(t1.getCreated())
        ).toList();
    }
}
