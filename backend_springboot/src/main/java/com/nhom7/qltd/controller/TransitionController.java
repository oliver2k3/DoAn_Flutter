package com.nhom7.qltd.controller;

import com.nhom7.qltd.dto.RequestDepositDto;
import com.nhom7.qltd.service.DepositRequestService;
import com.nhom7.qltd.service.TransitionService;
import com.nhom7.qltd.service.UsersService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/transition")
public class TransitionController {
    private final TransitionService transitionService;
    private final DepositRequestService depositRequestService;
    private final UsersService userService;
    @GetMapping("/current")
    public ResponseEntity<Object> searchMyPayment( @RequestHeader("Authorization") String token){
        return ResponseEntity.ok(transitionService.getMyTransition(token.substring(7)));
    }
    @GetMapping("/received")
    public ResponseEntity<Object> getReceivedTransitions(@RequestHeader("Authorization") String token) {
        return ResponseEntity.ok(transitionService.getReceivedTransitions(token.substring(7)));
    }

    @PostMapping("/create-request")
    public ResponseEntity<Object> createDepositRequest(@RequestBody RequestDepositDto requestDepositDto,  @RequestHeader("Authorization") String token) {
        Map<String, Object> responseBody = new HashMap<>();
       String email = userService.getEmailfromToken(token.substring(7));
        requestDepositDto.setRequesterEmail(email);
        try {
            depositRequestService.createDepositRequest(requestDepositDto);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException ie) {
            responseBody.put("error", ie.getMessage());
            return ResponseEntity.badRequest().body(responseBody);
        }
    }

    @PostMapping("/approve")
    public ResponseEntity<Object> approveDepositRequest(@RequestParam int requestId) {
        Map<String, Object> responseBody = new HashMap<>();
        try {
            depositRequestService.approveDepositRequest(requestId);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException ie) {
            responseBody.put("error", ie.getMessage());
            return ResponseEntity.badRequest().body(responseBody);
        }
    }
}
