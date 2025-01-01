package com.nhom7.qltd.mapper;

import com.nhom7.qltd.dto.GetUserInfoDto;
import com.nhom7.qltd.model.UserEntity;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface UserMapper {

    GetUserInfoDto entityToDto(UserEntity userEntity);

    UserEntity dtoToEntity(GetUserInfoDto getUserInfoDto);
}
