package model

// User struct represents a user in the system.
// It includes personal information such as gender, email, telephone, name, and password.
type User struct {
	Model

	// IsMale indicates the user's gender (true for male, false for female).
	IsMale bool `json:"is_male" gorm:"column:is_male"`

	// Email is the user's email address, must be unique.
	Email string `json:"email" gorm:"column:email;type:varchar(50);unique;"`

	// Telephone is the user's phone number, which can be null.
	Telephone NullString `json:"telephone" gorm:"column:telephone;type:varchar(11)"`

	// Name is the user's name (up to 25 characters).
	Name string `json:"name" gorm:"column:name;type:varchar(25);"`

	// Password is the user's hashed password.
	Password string `json:"password" gorm:"column:password;type:text;"`

	About string `json:"about" gorm:"column:about;type:text;"`
}

func (User) TableName() string {
	return "user"
}

// UserRelation struct represents a relationship between two users (a user and their friend).
// It tracks which users are friends with each other.
type UserRelation struct {
	Model

	// UserId is the ID of the user in the relationship.
	UserId uint `json:"userId" gorm:"column:user_id;uniqueIndex:uid_fid_idx"`

	// FriendId is the ID of the friend's user in the relationship.
	FriendId uint `json:"friendId" gorm:"column:friend_id;uniqueIndex:uid_fid_idx"`
}

// TableName overrides the default table name to "user_relation" for the UserRelation struct.
func (*UserRelation) TableName() string {
	return "user_relation"
}
