package com.backend_springboot.dto;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;

@Data
public class LoginDto implements Serializable {
    /** UID */
    @Serial
    private static final long serialVersionUID = 1L;
    private String email;
    private String password;

}
