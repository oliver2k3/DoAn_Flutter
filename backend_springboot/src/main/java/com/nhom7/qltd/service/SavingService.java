package com.nhom7.qltd.service;

import com.nhom7.qltd.dao.SavingDAO;
import com.nhom7.qltd.dto.SavingDto;
import com.nhom7.qltd.model.SavingEntity;
import com.nhom7.qltd.model.UserEntity;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SavingService {
    private final SavingDAO savingDAO;
    private final UsersService userService;

//    public void createSaving(String  email, Double depositAmount, Integer depositDuration, Double interestRate) {
//        UserEntity user = userService.getUserByEmail(email);
//        if (user.getBalance() < depositAmount) {
//            throw new IllegalArgumentException("Insufficient balance");
//        }
//
//        user.setBalance(user.getBalance() - depositAmount);
//        userService.updateUser(user);
//
//        SavingEntity savingEntity = new SavingEntity();
//        savingEntity.setEmail(email);
//        savingEntity.setDepositAmount(depositAmount);
//        savingEntity.setDepositDuration(depositDuration);
//        savingEntity.setInterestRate(interestRate);
//        savingEntity.setAmount(depositAmount);
//        savingEntity.setCreatedDate(LocalDateTime.now());
//        savingEntity.setMaturityDate(LocalDateTime.now().plusMonths(depositDuration));
//        savingEntity.setStatus("Active");
//
//        savingDAO.save(savingEntity);
//    }
    public void creatSaving2(SavingDto savingDto) {
        UserEntity user = userService.getUserByEmail(savingDto.getEmail());
        if (user.getBalance() < savingDto.getAmount()) {
            throw new IllegalArgumentException("Insufficient balance");
        }

        user.setBalance(user.getBalance() - savingDto.getAmount());
        userService.updateUser(user);
        SavingEntity savingEntity = new SavingEntity();
        savingEntity.setEmail(savingDto.getEmail());
        savingEntity.setAmount(savingDto.getAmount());
        savingEntity.setDepositDuration(savingDto.getDepositDuration());
        savingEntity.setInterestRate(savingDto.getInterestRate());
        savingEntity.setDepositAmount(savingDto.getAmount()*savingDto.getInterestRate());
        savingEntity.setCreatedDate(LocalDateTime.now());
        savingEntity.setMaturityDate(LocalDateTime.now().plusMonths(savingDto.getDepositDuration()));
        savingEntity.setStatus("Active");
        savingDAO.save(savingEntity);
    }

    public List<SavingEntity> getSavingsByEmail(String email) {
        return savingDAO.findByEmail(email);
    }
}