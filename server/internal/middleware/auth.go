package middleware

import (
	"context"
	"fmt"
	"mytodo/internal/db"
	"mytodo/internal/model"
	"net/http"
	"strconv"
	"time"

	"github.com/caarlos0/log"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt"
)

func Auth(ctx *gin.Context) {
	jwt := ctx.GetHeader("Authorization")

	if len(jwt) == 0 {
		log.Error("jwt is empty")
		ctx.Abort()
		return
	}

	_, claims, err := ParseToken(jwt)

	if err != nil {
		if claims.ExpiresAt < time.Now().Unix() {
			log.Error("token expired")
			id, err := strconv.ParseUint(claims.Id, 10, 64)
			if err != nil {
				log.WithError(err).Error("fail to parse id")
				ctx.Abort()
				return
			}
			jwt, err = ReleaseToken(uint(id))
			if err != nil {
				log.WithError(err).Error("releasing token")
				ctx.Abort()
				return
			}
			err = db.Rdb().Set(context.TODO(), fmt.Sprintf("user_%d", id), jwt, 7*24*time.Hour).Err()
			if err != nil {
				log.WithError(err).Error("setting cache")
				ctx.Abort()
				return
			}
			ctx.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"msg": "token expired", "data": jwt})
			return
		}

		log.Error("invalid token")
		ctx.Abort()
		return
	}

	var user model.User
	err = db.SQL().Table("user").Where("id = ?", claims.Id).First(&user).Error
	if err != nil {
		log.WithError(err).Error("fail to get user")
		ctx.Abort()
		return
	}

	ctx.Set("user", user)
}

var jwtKey = []byte("my_todo_key")

func ReleaseToken(id uint) (string, error) {
	now := time.Now()
	expirationTime := now.Add(7 * 24 * time.Hour)
	claims := jwt.StandardClaims{
		Id:        fmt.Sprintf("%d", id),
		ExpiresAt: expirationTime.Unix(),
		IssuedAt:  now.Unix(),
		Issuer:    "org.my_todo",
		Subject:   "user token",
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenStr, err := token.SignedString(jwtKey)
	if err != nil {
		return "", err
	}
	return tokenStr, nil
}

func ParseToken(tokenString string) (*jwt.Token, jwt.StandardClaims, error) {
	tokenString = tokenString[7:]
	claims := jwt.StandardClaims{}
	token, err := jwt.ParseWithClaims(tokenString, &claims, func(token *jwt.Token) (i interface{}, err error) {
		return jwtKey, nil
	})
	return token, claims, err
}
