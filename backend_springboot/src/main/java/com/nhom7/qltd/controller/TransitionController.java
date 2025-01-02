package com.nhom7.qltd.controller;

import com.nhom7.qltd.service.TransitionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/transition")
public class TransitionController {
    private final TransitionService transitionService;

    @GetMapping("/current")
    public ResponseEntity<Object> searchMyPayment( @RequestHeader("Authorization") String token){
        return ResponseEntity.ok(transitionService.getMyTransition(token.substring(7)));
    }
    @GetMapping("/received")
    public ResponseEntity<Object> getReceivedTransitions(@RequestHeader("Authorization") String token) {
        return ResponseEntity.ok(transitionService.getReceivedTransitions(token.substring(7)));
    }
}
