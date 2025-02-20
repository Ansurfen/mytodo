package api

import "mytodo/internal/model"

type UserSignRequest struct {
	Email    string `json:"email"`
	Password string `json:"pwd"`
}

type UserSignResponse struct {
	JWT string `json:"jwt"`
}

type UserGetResponse struct {
	model.User
}

type UserOnlineResponse struct {
	Users []string `json:"users"`
}

type FriendNewRequest struct {
	FriendId uint `json:"friendId"`
}
