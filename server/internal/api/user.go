package api

import (
	"mime/multipart"
	"mytodo/internal/model"
)

type UserSignUpRequest struct {
	Email     string `json:"email"`
	Password  string `json:"pwd"`
	Username  string `json:"username"`
	Telephone string `json:"telephone"`
	IsMale    bool   `json:"is_male"`
	OTP       string `json:"otp"`
}

type UserVerifyOTPRequest struct {
	Email string `json:"email"`
}

type UserVerifyOTPResponse struct {
	OTP string `json:"otp"`
}

type UserLoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"pwd"`
}

type UserRecoverRequest struct {
	Email    string `json:"email"`
	Password string `json:"pwd"`
	OTP      string `json:"otp"`
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

type UserEditRequest struct {
	Profile   *multipart.FileHeader `form:"profile"`
	Name      string                `form:"name"`
	Telephone string                `form:"telephone"`
	About     string                `form:"about"`
	Email     string                `form:"email"`
	IsMale    string                `form:"is_male"`
}

type FriendNewRequest struct {
	FriendId uint `json:"friendId"`
}

type FriendCommitRequest struct {
	NotificationId uint   `json:"notification_id"`
	Status         string `json:"status"`
}

type FriendPostGetRequest struct {
	FriendId uint `json:"friendId"`
	Page     int  `json:"page"`
	Limit    int  `json:"limit"`
}
