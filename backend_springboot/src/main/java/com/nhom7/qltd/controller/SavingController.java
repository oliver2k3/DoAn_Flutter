package com.nhom7.qltd.controller;

import com.nhom7.qltd.dto.SavingDto;
import com.nhom7.qltd.model.SavingEntity;
import com.nhom7.qltd.service.SavingService;
import com.nhom7.qltd.service.UsersService;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/saving")
public class SavingController {
    private final SavingService savingService;
    private final UsersService userService;

//    @PostMapping("/deposit")
//    public void createSaving(@RequestBody Map<String, Object> request, @RequestHeader("Authorization") String token) {
//        String email = userService.getEmailfromToken(token.substring(7));
//
//        Double depositAmount = (Double) request.get("amount");
//        Integer depositDuration = (Integer) request.get("depositDuration");
//        Double interestRate = (Double) request.get("interestRate");
//
//        savingService.createSaving(email, depositAmount, depositDuration, interestRate);
//    }
    @PostMapping("/deposit2")
    public ResponseEntity<Object> createSaving(@RequestBody SavingDto savingDto, @RequestHeader("Authorization") String token) {
        Map<String, Object> responseBody = new HashMap<>();
        try {
        String email = userService.getEmailfromToken(token.substring(7));
        savingDto.setEmail(email);
        savingService.creatSaving2(savingDto);
        return ResponseEntity.ok().build();
        } catch (IllegalArgumentException ie) {
            responseBody.put("error", ie.getMessage());
            return ResponseEntity.badRequest().body(responseBody);
        }
        catch (DuplicateKeyException de) {
            responseBody.put("error", de.getMessage());
            return ResponseEntity.status(HttpStatus.CONFLICT).body(responseBody);
        }
    }
    @GetMapping("/my-savings")
    public ResponseEntity<Object> getMySavings(@RequestHeader("Authorization") String token) {
        Map<String, Object> responseBody = new HashMap<>();
        try {
            String email = userService.getEmailfromToken(token.substring(7));
            List<SavingEntity> savings = savingService.getSavingsByEmail(email);
            return ResponseEntity.ok(savings);
        } catch (IllegalArgumentException ie) {
            responseBody.put("error", ie.getMessage());
            return ResponseEntity.badRequest().body(responseBody);
        }
    }
}