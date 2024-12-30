package com.backend_springboot.mapper;


import com.backend_springboot.dto.GetUserInfoDto;
import com.backend_springboot.model.UserEntity;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface UserMapper {

    GetUserInfoDto entityToDto(UserEntity userEntity);

    UserEntity dtoToEntity(GetUserInfoDto getUserInfoDto);
}
