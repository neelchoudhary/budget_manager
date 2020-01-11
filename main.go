package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/gorilla/mux"
	_ "github.com/lib/pq"

	//"google.golang.org/genproto/googleapis/type/date"
	"os"
	"strconv"

	"github.com/plaid/plaid-go/plaid"
)

const (
	host     = "localhost"
	port     = 5432
	user     = "postgres"
	password = "your-password"
	dbname   = "neel_demo"
)

var (
	plaidClientID  = os.Getenv("PLAID_CLIENT_ID")
	plaidSecret    = os.Getenv("PLAID_SECRET")
	plaidPublicKey = os.Getenv("PLAID_PUBLIC_KEY")
	appPort        = os.Getenv("APP_PORT")
)

var clientOptions = plaid.ClientOptions{
	plaidClientID,
	plaidSecret,
	plaidPublicKey,
	plaid.Development, // Available environments are Sandbox, Development, and Production
	&http.Client{},
}

var client, err = plaid.NewClient(clientOptions)

/*
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
	fullName TEXT NOT NULL,
	email TEXT NOT NULL,
  password TEXT NOT NULL
);

CREATE TABLE items (
	id SERIAL PRIMARY KEY,
	item_id_plaid TEXT NOT NULL,
	access_token_plaid TEXT NOT NULL,
  user_id INT NOT NULL,
  institution_id_plaid TEXT,
  institution_name TEXT,
  institution_color TEXT,
  institution_logo TEXT
);

CREATE TABLE institutions (
	id SERIAL PRIMARY KEY,
	institution_id_plaid TEXT NOT NULL,
	name TEXT NOT NULL
);

CREATE TABLE accounts (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
	item_id INT NOT NULL,
	account_id_plaid TEXT NOT NULL,
	current_balance FLOAT8,
	account_name TEXT,
	official_name TEXT,
	account_type TEXT,
	account_subtype TEXT,
  account_mask TEXT,
  institution_id_plaid TEXT,
  selected BOOLEAN
);

CREATE TABLE transactions (
	id SERIAL PRIMARY KEY,
	item_id INT NOT NULL,
	account_id INT NOT NULL,
  category_id INT NOT NULL,
  budget_name TEXT NOT NULL,
	transaction_id_plaid TEXT NOT NULL,
	transaction_name TEXT,
	transaction_amount FLOAT8,
  transaction_date DATE
);

CREATE TABLE categories (
	id SERIAL PRIMARY KEY,
	category_id_plaid TEXT NOT NULL,
	category_group TEXT,
	category1 TEXT,
	category2 TEXT,
	category3 TEXT
);

CREATE TABLE budgets (
  id SERIAL PRIMARY KEY,
  budget_category TEXT NOT NULL,
  category_id_plaid TEXT NOT NULL,
  name TEXT NOT NULL
);
*/

// User ...
type User struct {
	ID       int64  `json:"id"`
	FullName string `json:"fullName"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

// Item ...
type Item struct {
	ID                 int64  `json:"id"`
	ItemIDPlaid        string `json:"item_id_plaid"`
	AccessTokenPlaid   string `json:"access_token_plaid"`
	UserID             int64  `json:"user_id"`
	InstitutionIDPlaid string `json:"institution_id_plaid"`
	InstitutionName    string `json:"institution_name"`
	InstitutionColor   string `json:"institution_color"`
	InstitutionLogo    string `json:"institution_logo"`
}

// Account ...
type Account struct {
	ID                 int64   `json:"id"`
	UserID             int64   `json:"user_id"`
	ItemID             int64   `json:"item_id"`
	AccountIDPlaid     string  `json:"account_id_plaid"`
	CurrentBalance     float64 `json:"current_balance"`
	AccountName        string  `json:"account_name"`
	OfficialName       string  `json:"official_name"`
	AccountType        string  `json:"account_type"`
	AccountSubType     string  `json:"account_subtype"`
	AccountMask        string  `json:"account_mask"`
	InstitutionIDPlaid string  `json:"institution_id_plaid"`
	Selected           bool    `json:"selected"`
}

// Transaction ...
type Transaction struct {
	ID                 int64   `json:"id"`
	ItemID             int64   `json:"item_id"`
	AccountID          int64   `json:"account_id"`
	CategoryID         int64   `json:"category_id"`
	BudgetName         string  `json:"budget_name"`
	TransactionIDPlaid string  `json:"transaction_id_plaid"`
	Name               string  `json:"transaction_name"`
	Amount             float32 `json:"transaction_amount"`
	Date               string  `json:"transaction_date"`
}

// Category ...
type Category struct {
	ID              int64  `json:"id"`
	CategoryIDPlaid string `json:"category_id_plaid"`
	Group           string `json:"group"`
	Category1       string `json:"category1"`
	Category2       string `json:"category2"`
	Category3       string `json:"category3"`
}

// Budget ...
type Budget struct {
	ID              int64  `json:"id"`
	CategoryIDPlaid string `json:"category_id_plaid"`
	BudgetCategory  string `json:"budget_category"`
	Name            string `json:"name"`
}

// Webhook ...
type Webhook struct {
	WebhookType string `json:"webhook_type"`
	WebhookCode string `json:"webhook_code"`
	ItemIDPlaid string `json:"item_id"`
}

var db *sql.DB

// Connect to postgresql db
func init() {
	var err error
	psqlInfo := fmt.Sprintf("host=%s port=%d user=%s "+
		"password=%s dbname=%s sslmode=disable",
		host, port, user, password, dbname)
	db, err = sql.Open("postgres", psqlInfo)
	if err != nil {
		panic(err)
	}

	if err = db.Ping(); err != nil {
		panic(err)
	}

	fmt.Println("You connected to your database.")
}

// Get single user, works
func getUser(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	userID := params["user_id"]
	if userID == "" {
		http.Error(w, http.StatusText(400), http.StatusBadRequest)
		return
	}

	row := db.QueryRow("SELECT * FROM users WHERE id = $1", userID)

	user := User{}
	err := row.Scan(&user.ID, &user.FullName, &user.Email, &user.Password)
	switch {
	case err == sql.ErrNoRows:
		http.NotFound(w, r)
		return
	case err != nil:
		http.Error(w, http.StatusText(500), http.StatusInternalServerError)
		return
	}

	fmt.Println("Get user with id ", userID)
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(user); err != nil {
		panic(err)
	}
}

// Add new user, works
func createUser(w http.ResponseWriter, r *http.Request) {
	// get form values

	var user User
	_ = json.NewDecoder(r.Body).Decode(&user)

	// validate form values
	if user.FullName == "" || user.Email == "" || user.Password == "" {
		http.Error(w, http.StatusText(400)+err.Error(), http.StatusBadRequest)
		return
	}

	// insert values
	var userID int64
	err := db.QueryRow("INSERT INTO users (FULLNAME, EMAIL, PASSWORD) VALUES ($1, $2, $3) RETURNING id", user.FullName, user.Email, user.Password).Scan(&userID)
	if err != nil {
		http.Error(w, http.StatusText(500)+err.Error(), http.StatusInternalServerError)
		return
	}

	user.ID = userID

	fmt.Println("Create user with id: ", user.ID)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(user); err != nil {
		panic(err)
	}

}

// Update user TODO fix args and test
func updateUser(w http.ResponseWriter, r *http.Request) {
	// Get isbn
	params := mux.Vars(r)
	userID := params["user_id"]
	if userID == "" {
		http.Error(w, http.StatusText(400), http.StatusBadRequest)
		return
	}

	row := db.QueryRow("SELECT * FROM users WHERE id = $1", userID)

	// Validate row
	user := User{}
	err := row.Scan(&user.ID, &user.FullName, &user.Email, &user.Password)
	switch {
	case err == sql.ErrNoRows:
		http.NotFound(w, r)
		return
	case err != nil:
		http.Error(w, http.StatusText(500), http.StatusInternalServerError)
		return
	}

	_ = json.NewDecoder(r.Body).Decode(&user)

	// validate form values
	if user.FullName == "" || user.Email == "" || user.Password == "" {
		http.Error(w, http.StatusText(400), http.StatusBadRequest)
		return
	}

	// insert values
	_, err = db.Exec("UPDATE users SET id=$1 fullname=$2, email=$3, password=$4 WHERE id=$1;", userID, &user.FullName, &user.Email, &user.Password)
	if err != nil {
		http.Error(w, http.StatusText(500), http.StatusInternalServerError)
		return
	}
	fmt.Println("Update user with id: ", user.ID)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(user); err != nil {
		panic(err)
	}
}

// Delete user
func deleteUser(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	userID := params["id"]
	if userID == "" {
		http.Error(w, http.StatusText(400), http.StatusBadRequest)
		return
	}

	// Get all item ids for this user, then loop through and delete all transactions and accounts for each item

	// _, err := db.Exec("DELETE FROM transactions WHERE item_id=$1;", itemID)
	// if err != nil {
	// 	http.Error(w, http.StatusText(500)+err.Error(), http.StatusInternalServerError)
	// 	return
	// }

	// _, err = db.Exec("DELETE FROM accounts WHERE item_id=$1;", itemID)
	// if err != nil {
	// 	http.Error(w, http.StatusText(500)+err.Error(), http.StatusInternalServerError)
	// 	return
	// }

	_, err = db.Exec("DELETE FROM items WHERE user_id=$1;", userID)
	if err != nil {
		http.Error(w, http.StatusText(500)+err.Error(), http.StatusInternalServerError)
		return
	}

	_, err = db.Exec("DELETE FROM users WHERE id=$1;", userID)
	if err != nil {
		http.Error(w, http.StatusText(500), http.StatusInternalServerError)
		return
	}

	fmt.Println("Delete user with id: ", userID)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
}

// Add new item
func createItem(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	userID := params["user_id"]
	publicToken := params["public_token"]
	institutionIDPlaid := params["institution_id_plaid"]
	accountName := params["account_name"]
	accountMask := params["account_mask"]
	accountSubtype := params["account_subtype"]

	// Pass in account name, account mask.

	if publicToken == "" {
		fmt.Println("Errored - public token invalid ", publicToken)
		http.Error(w, http.StatusText(400), http.StatusBadRequest)
		return
	}

	// Check if user already created this item.
	// Get accounts from items and check if same as account name and account mask.
	row := db.QueryRow("SELECT EXISTS(SELECT 1 FROM accounts WHERE user_id = $1 AND institution_id_plaid = $2 AND account_name = $3 AND account_subtype = $4 AND account_mask = $5);", userID, institutionIDPlaid, accountName, accountSubtype, accountMask)
	// Validate row
	var exists bool
	err := row.Scan(&exists)
	switch {
	case err == sql.ErrNoRows:
		http.Error(w, http.StatusText(500)+err.Error(), http.StatusInternalServerError)
		return
	case err != nil:
		http.Error(w, http.StatusText(500)+err.Error(), http.StatusInternalServerError)
		return
	}

	if exists {
		http.Error(w, http.StatusText(406)+" Account already exists", http.StatusNotAcceptable)
		return
	}

	response, err := client.ExchangePublicToken(publicToken)
	accessTokenPlaid := response.AccessToken
	itemIDPlaid := response.ItemID

	if err != nil {
		fmt.Println("Errored - failed to exchange ")
		http.Error(w, http.StatusText(400)+err.Error(), http.StatusBadRequest)
		return
	}

	userIDInt, err := strconv.ParseInt(userID, 10, 64)
	if err != nil {
		fmt.Println("Errored - could not convert user id to int: ", userID)
		http.Error(w, http.StatusText(406)+"User id must be a number", http.StatusNotAcceptable)
		return
	}

	var item Item
	item.UserID = userIDInt
	item.AccessTokenPlaid = accessTokenPlaid
	item.ItemIDPlaid = itemIDPlaid

	institutionResponse, err := client.GetInstitutionByIDWithOptions(institutionIDPlaid, plaid.GetInstitutionByIDOptions{
		IncludeOptionalMetadata: true,
	})

	if err != nil {
		fmt.Println("Errored - failed to get institution by id")
		http.Error(w, http.StatusText(400)+err.Error(), http.StatusBadRequest)
		return
	}
	item.InstitutionIDPlaid = institutionResponse.Institution.ID
	item.InstitutionName = institutionResponse.Institution.Name
	item.InstitutionColor = institutionResponse.Institution.PrimaryColor
	item.InstitutionLogo = institutionResponse.Institution.Logo

	// validate form values
	if item.AccessTokenPlaid == "" || item.ItemIDPlaid == "" {
		fmt.Println("Errored - failed validation ")
		http.Error(w, http.StatusText(400), http.StatusBadRequest)
		return
	}

	var itemID int64
	// insert values
	err = db.QueryRow("INSERT INTO items (ITEM_ID_PLAID, ACCESS_TOKEN_PLAID, USER_ID, INSTITUTION_ID_PLAID, INSTITUTION_NAME, INSTITUTION_COLOR, INSTITUTION_LOGO) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id",
		item.ItemIDPlaid, item.AccessTokenPlaid, item.UserID, item.InstitutionIDPlaid, item.InstitutionName, item.InstitutionColor, item.InstitutionLogo).Scan(&itemID)
	if err != nil {
		fmt.Println("last insert id failed. ")
		http.Error(w, http.StatusText(500)+err.Error(), http.StatusInternalServerError)
		return
	}

	item.ID = itemID

	// Do not return access token
	item.AccessTokenPlaid = ""

	fmt.Println("Create item with id: ", item.ID)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(item); err != nil {
		fmt.Println("Errored - just failed ")
		panic(err)
	}

}

// Get all items for a user
func getItems(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	userID := params["user_id"]
	if userID == "" {
		http.Error(w, http.StatusText(400), http.StatusBadRequest)
		return
	}

	rows, err := db.Query("SELECT * FROM items WHERE user_id = $1", userID)
	if err != nil {
		http.Error(w, http.StatusText(400)+err.Error(), http.StatusBadRequest)
		return
	}
	defer rows.Close()
	items := make([]Item, 0)
	for rows.Next() {
		item := Item{}
		err := rows.Scan(&item.ID,
			&item.ItemIDPlaid, &item.AccessTokenPlaid, &item.UserID, &item.InstitutionIDPlaid,
			&item.InstitutionName, &item.InstitutionColor, &item.InstitutionLogo)
		if err != nil {
			http.Error(w, http.StatusText(500), 500)
			return
		}
		// Do not return access token
		item.AccessTokenPlaid = ""
		items = append(items, item)
	}
	if err = rows.Err(); err != nil {
		http.Error(w, http.StatusText(500), 500)
		return
	}

	fmt.Println("Get all items with user id ", userID)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(items); err != nil {
		panic(err)
	}
}

// Delete item
func deleteItem(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	userID := params["user_id"]
	itemID := params["item_id"]
	if itemID == "" && userID == "" {
		http.Error(w, http.StatusText(400)+" Bad inputs", http.StatusBadRequest)
		return
	}

	accessToken := getAccessToken(itemID)
	response, err := client.RemoveItem(accessToken)
	if !response.Removed {
		http.Error(w, http.StatusText(400)+" Failed to remove item. "+err.Error(), http.StatusBadRequest)
		return
	}

	if err != nil {
		http.Error(w, http.StatusText(400)+err.Error(), http.StatusBadRequest)
		return
	}

	_, err = db.Exec("DELETE FROM transactions WHERE item_id=$1;", itemID)
	if err != nil {
		http.Error(w, http.StatusText(500)+err.Error(), http.StatusInternalServerError)
		return
	}

	_, err = db.Exec("DELETE FROM accounts WHERE item_id=$1;", itemID)
	if err != nil {
		http.Error(w, http.StatusText(500)+err.Error(), http.StatusInternalServerError)
		return
	}

	_, err = db.Exec("DELETE FROM items WHERE user_id=$1 AND id=$2;", userID, itemID)
	if err != nil {
		http.Error(w, http.StatusText(500)+err.Error(), http.StatusInternalServerError)
		return
	}
	fmt.Println("Delete item with id: ", itemID)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
}

// Get access token
func getAccessToken(itemID string) string {
	row := db.QueryRow("SELECT * FROM items WHERE id = $1", itemID)

	item := Item{}
	err := row.Scan(&item.ID, &item.ItemIDPlaid, &item.AccessTokenPlaid, &item.UserID, &item.InstitutionIDPlaid, &item.InstitutionName, &item.InstitutionColor, &item.InstitutionLogo)
	//todo error check
	if err != nil {
		fmt.Println("Failed to get access token. " + err.Error())
	}

	fmt.Println("Got access token for item id: ", itemID)
	return item.AccessTokenPlaid
}

// Get public token ??
func getPublicToken(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	itemID := params["item_id"]
	if itemID == "" {
		http.Error(w, http.StatusText(400), http.StatusBadRequest)
		return
	}

	accessToken := getAccessToken(itemID)
	response, err := client.CreatePublicToken(accessToken)

	if err != nil {
		fmt.Println("Failed to create public token")
		http.Error(w, http.StatusText(400)+err.Error(), http.StatusBadRequest)
		return
	}

	fmt.Println("Got access token for item id: ", itemID)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(response.PublicToken); err != nil {
		panic(err)
	}
}

// Add all new accounts associated with item.
func createAccounts(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	userID := params["user_id"]
	itemID := params["item_id"]
	institutionIDPlaid := params["institution_id_plaid"]
	if itemID == "" {
		http.Error(w, http.StatusText(400)+err.Error(), http.StatusBadRequest)
		return
	}

	accessToken := getAccessToken(itemID)
	response, err := client.GetAuth(accessToken)

	if err != nil {
		http.Error(w, http.StatusText(400)+err.Error(), http.StatusBadRequest)
		return
	}

	userIDInt, err := strconv.ParseInt(userID, 10, 64)
	if err != nil {
		http.Error(w, http.StatusText(406)+err.Error()+" User ID must be a number "+userID, http.StatusNotAcceptable)
		return
	}

	itemIDInt, err := strconv.ParseInt(itemID, 10, 64)
	if err != nil {
		http.Error(w, http.StatusText(406)+err.Error()+" Item ID must be a number "+itemID, http.StatusNotAcceptable)
		return
	}

	plaidAccounts := response.Accounts
	accounts := make([]Account, 0)
	for i := 0; i < len(plaidAccounts); i++ {
		account := Account{}
		account.UserID = userIDInt
		account.AccountIDPlaid = plaidAccounts[i].AccountID
		account.AccountName = plaidAccounts[i].Name
		account.OfficialName = plaidAccounts[i].OfficialName
		account.AccountType = plaidAccounts[i].Type
		account.AccountSubType = plaidAccounts[i].Subtype
		account.AccountMask = plaidAccounts[i].Mask
		account.CurrentBalance = plaidAccounts[i].Balances.Available
		account.ItemID = itemIDInt
		account.InstitutionIDPlaid = institutionIDPlaid
		account.Selected = false
		// insert values
		var accountID int64
		err = db.QueryRow("INSERT INTO accounts (USER_ID, ITEM_ID, ACCOUNT_ID_PLAID, CURRENT_BALANCE, ACCOUNT_NAME, OFFICIAL_NAME, ACCOUNT_TYPE, ACCOUNT_SUBTYPE, ACCOUNT_MASK, INSTITUTION_ID_PLAID, SELECTED) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) RETURNING id",
			account.UserID, account.ItemID, account.AccountIDPlaid, account.CurrentBalance, account.AccountName,
			account.OfficialName, account.AccountType, account.AccountSubType, account.AccountMask,
			account.InstitutionIDPlaid, account.Selected).Scan(&accountID)

		if err != nil {
			http.Error(w, http.StatusText(500)+err.Error(), http.StatusInternalServerError)
			return
		}

		account.ID = accountID
		accounts = append(accounts, account)

		fmt.Println("Create account with id: ", accountID)
	}

	fmt.Println("Created account(s)")

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(accounts); err != nil {
		panic(err)
	}
}

// Choose accounts to show to the user.
func toggleSelectAccountPlaidID(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	itemID := params["item_id"]
	accountIDPlaid := params["account_id_plaid"]
	showAccount := params["show_account"]

	if itemID == "" && accountIDPlaid == "" {
		http.Error(w, http.StatusText(400)+err.Error(), http.StatusBadRequest)
		return
	}

	// Parse itemID to int
	itemIDInt, err := strconv.ParseInt(itemID, 10, 64)
	if err != nil {
		http.Error(w, http.StatusText(406)+err.Error()+" ID must be a number "+itemID, http.StatusNotAcceptable)
		return
	}

	// Parse showAccount to boolean
	showAccountBool, err := strconv.ParseBool(showAccount)
	if err != nil {
		http.Error(w, http.StatusText(406)+err.Error()+" showAccount must be a bool "+itemID, http.StatusNotAcceptable)
		return
	}

	_, err = db.Exec("UPDATE accounts SET selected=$3 WHERE item_id=$1 AND account_id_plaid=$2;", itemIDInt, accountIDPlaid, showAccountBool)
	if err != nil {
		http.Error(w, http.StatusText(500), http.StatusInternalServerError)
		return
	}
	fmt.Println("Selected account with plaid account id: ", accountIDPlaid, " ", showAccount)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	// update getAccounts to only get accounts that are selected. Update db to include selected BOOLEAN field.
}

// Choose accounts to show to the user.
func toggleSelectAccountID(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	itemID := params["item_id"]
	accountID := params["account_id"]
	showAccount := params["show_account"]

	if itemID == "" && accountID == "" {
		http.Error(w, http.StatusText(400)+err.Error(), http.StatusBadRequest)
		return
	}

	// Parse itemID to int
	itemIDInt, err := strconv.ParseInt(itemID, 10, 64)
	if err != nil {
		http.Error(w, http.StatusText(406)+err.Error()+" ID must be a number "+itemID, http.StatusNotAcceptable)
		return
	}

	// Parse showAccount to boolean
	showAccountBool, err := strconv.ParseBool(showAccount)
	if err != nil {
		http.Error(w, http.StatusText(406)+err.Error()+" showAccount must be a bool "+itemID, http.StatusNotAcceptable)
		return
	}

	_, err = db.Exec("UPDATE accounts SET selected=$3 WHERE item_id=$1 AND id=$2;", itemIDInt, accountID, showAccountBool)
	if err != nil {
		http.Error(w, http.StatusText(500), http.StatusInternalServerError)
		return
	}
	fmt.Println("Selected account with account id: ", accountID, " ", showAccount)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	// update getAccounts to only get accounts that are selected. Update db to include selected BOOLEAN field.
}

// Get all accounts for an item
func getAccounts(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	itemID := params["item_id"]
	if itemID == "" {
		http.Error(w, http.StatusText(400)+err.Error(), http.StatusBadRequest)
		return
	}

	rows, err := db.Query("SELECT * FROM accounts WHERE item_id = $1", itemID)
	if err != nil {
		http.Error(w, http.StatusText(400)+err.Error(), http.StatusBadRequest)
		return
	}
	defer rows.Close()
	accounts := make([]Account, 0)
	for rows.Next() {
		account := Account{}
		err := rows.Scan(&account.ID, &account.UserID, &account.ItemID,
			&account.AccountIDPlaid, &account.CurrentBalance, &account.AccountName,
			&account.OfficialName, &account.AccountType, &account.AccountSubType, &account.AccountMask,
			&account.InstitutionIDPlaid, &account.Selected)
		if err != nil {
			http.Error(w, http.StatusText(500)+err.Error(), 500)
			return
		}
		accounts = append(accounts, account)
	}
	if err = rows.Err(); err != nil {
		http.Error(w, http.StatusText(500)+err.Error(), 500)
		return
	}

	fmt.Println("Get all accounts with item id $1", itemID)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(accounts); err != nil {
		panic(err)
	}
}

// Update account
func updateAccount(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	itemID := params["item_id"]
	accountID := params["account_id"]
	if itemID == "" && accountID == "" {
		fmt.Println("Failed, itemId: ", itemID)
		http.Error(w, http.StatusText(400)+err.Error(), http.StatusBadRequest)
		return
	}

	// Get accountIDPlaid using routing number
	row := db.QueryRow("SELECT * FROM accounts WHERE item_id = $1 AND id = $2", itemID, accountID)

	account := Account{}
	err := row.Scan(&account.ID, &account.UserID, &account.ItemID,
		&account.AccountIDPlaid, &account.CurrentBalance, &account.AccountName,
		&account.OfficialName, &account.AccountType, &account.AccountSubType, &account.AccountMask,
		&account.InstitutionIDPlaid, &account.Selected)
	switch {
	case err == sql.ErrNoRows:
		http.NotFound(w, r)
		return
	case err != nil:
		http.Error(w, http.StatusText(500), http.StatusInternalServerError)
		return
	}

	accessToken := getAccessToken(itemID)
	response, err := client.GetAuth(accessToken)
	if err != nil {
		http.Error(w, http.StatusText(400), http.StatusBadRequest)
		return
	}

	for i := 0; i < len(response.Accounts); i++ {
		accoundIDPlaid := response.Accounts[i].AccountID
		if account.AccountIDPlaid == accoundIDPlaid {
			// Found the new account values
			newAccount := response.Accounts[i]
			// insert values
			_, err = db.Exec("UPDATE accounts SET CURRENT_BALANCE=$3, ACCOUNT_NAME=$4, OFFICIAL_NAME=$5, ACCOUNT_TYPE=$6, ACCOUNT_SUBTYPE=$7 WHERE item_id=$1 AND id=$2",
				itemID, accountID, newAccount.Balances.Available, newAccount.Name, newAccount.OfficialName, newAccount.Type, newAccount.Subtype)

			if err != nil {
				http.Error(w, http.StatusText(500)+err.Error(), http.StatusInternalServerError)
				return
			}
		}
	}

	fmt.Println("Updated account with id: ", accountID)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
}

// Delete account
func deleteAccount(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	itemID := params["item_id"]
	accountID := params["account_id"]
	if itemID == "" && accountID == "" {
		http.Error(w, http.StatusText(400)+" Bad inputs", http.StatusBadRequest)
		return
	}

	_, err := db.Exec("DELETE FROM transactions WHERE item_id=$1 AND account_id=$2;", itemID, accountID)
	if err != nil {
		http.Error(w, http.StatusText(500)+err.Error(), http.StatusInternalServerError)
		return
	}

	_, err = db.Exec("DELETE FROM accounts WHERE item_id=$1 AND id=$2;", itemID, accountID)
	if err != nil {
		http.Error(w, http.StatusText(500)+err.Error(), http.StatusInternalServerError)
		return
	}

	fmt.Println("Delete account with id: ", accountID)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
}

// Create for transactions since the given start date.
func createTransactionsInitial(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	itemID := params["item_id"]
	//	startDate := params["start_date"]
	startDate := "2015-01-01"
	// input := "2015-01-01"
	// layout := "2006-01-02"
	// t, _ := time.Parse(layout, input)
	endDate := time.Now().Local().Format("2006-01-02")
	//	offset := params["offset"]
	if itemID == "" {
		http.Error(w, http.StatusText(400), http.StatusBadRequest)
		return
	}

	_, err = db.Exec("DELETE FROM transactions WHERE item_id = $1", itemID)
	if err != nil {
		http.Error(w, http.StatusText(400)+err.Error(), http.StatusBadRequest)
		return
	}

	isMore := true
	paginate := 0
	for isMore {
		isMore = createTransactionHelper(w, r, itemID, startDate, endDate, paginate)
		paginate += 500
		fmt.Println("Paginating: ", paginate)
	}

	fmt.Println("Create transactions initial with item id: ", itemID)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
}

// Create for transactions since the given start date.
func createTransactionsInitialMethod(w http.ResponseWriter, r *http.Request, itemIDPlaid string) {
	startDate := "2015-01-01"
	endDate := time.Now().Local().Format("2006-01-02")
	//	offset := params["offset"]
	if itemIDPlaid == "" {
		http.Error(w, http.StatusText(400), http.StatusBadRequest)
		return
	}
	var itemIDInt int64
	err = db.QueryRow("SELECT id FROM items WHERE item_id_plaid = $1", itemIDPlaid).Scan(&itemIDInt)
	itemID := strconv.Itoa(int(itemIDInt))

	_, err = db.Exec("DELETE FROM transactions WHERE item_id = $1", itemID)
	if err != nil {
		http.Error(w, http.StatusText(400)+err.Error(), http.StatusBadRequest)
		return
	}

	isMore := true
	paginate := 0
	for isMore {
		isMore = createTransactionHelper(w, r, itemID, startDate, endDate, paginate)
		paginate += 500
		fmt.Println("Paginating: ", paginate)
	}

	fmt.Println("Create transactions2 initial with item id: ", itemID)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
}

// Create for transactions from now till 10 days ago.
func createTransactionsUpdate(w http.ResponseWriter, r *http.Request, itemIDPlaid string) {
	// YYYY-MM-DD
	// startDate := "2019-01-05"
	// endDate := "2020-01-05"
	endDate := time.Now().Local().Format("2006-01-02")
	startDate := time.Now().Local().Add(-10 * 24 * time.Hour).Format("2006-01-02")
	var itemIDInt int64
	err = db.QueryRow("SELECT id FROM items WHERE item_id_plaid = $1", itemIDPlaid).Scan(&itemIDInt)
	itemID := strconv.Itoa(int(itemIDInt))

	_, err = db.Exec("DELETE FROM transactions WHERE item_id = $1 AND transaction_date >= $2::date", itemID, startDate)
	if err != nil {
		http.Error(w, http.StatusText(400)+err.Error(), http.StatusBadRequest)
		return
	}

	isMore := true
	paginate := 0
	for isMore {
		isMore = createTransactionHelper(w, r, itemID, startDate, endDate, paginate)
		paginate += 500
		fmt.Println("Paginating: ", paginate)
	}
	fmt.Println("Create transactions update with item id: ", itemID)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
}

func createTransactionHelper(w http.ResponseWriter, r *http.Request, itemID string, startDate string, endDate string, offset int) bool {
	// insert values
	accessToken := getAccessToken(itemID)
	response, err := client.GetTransactionsWithOptions(accessToken, plaid.GetTransactionsOptions{
		StartDate:  startDate,
		EndDate:    endDate,
		AccountIDs: nil,
		Count:      500,
		Offset:     offset,
	})
	if err != nil {
		http.Error(w, http.StatusText(400)+err.Error(), http.StatusBadRequest)
		return false
	}

	budgets := getBudgets(w, r)
	if budgets == nil {
		http.Error(w, http.StatusText(400)+" Unable to get budgets", http.StatusBadRequest)
		return false
	}

	for j := 0; j < len(response.Transactions); j++ {
		transaction := response.Transactions[j]
		var transactionID int64
		var categoryID int64
		err = db.QueryRow("SELECT id FROM categories WHERE category_id_plaid = $1", transaction.CategoryID).Scan(&categoryID)
		if err != nil {
			fmt.Println("Errored in getting category id: ", transaction.CategoryID)
			http.Error(w, http.StatusText(500)+err.Error(), http.StatusInternalServerError)
			return false
		}

		var budgetName string
		for _, budget := range budgets {
			if budget.CategoryIDPlaid == transaction.CategoryID {
				budgetName = budget.Name
				break
			}
		}

		if budgetName == "" {
			for _, budget := range budgets {
				if budget.CategoryIDPlaid == transaction.CategoryID[:len(transaction.CategoryID)-3] {
					budgetName = budget.Name
					break
				}
			}
		}

		if budgetName == "" {
			for _, budget := range budgets {
				if budget.CategoryIDPlaid == transaction.CategoryID[:len(transaction.CategoryID)-5] {
					budgetName = budget.Name
					break
				}
			}
		}

		var accountID int64
		err = db.QueryRow("SELECT id FROM accounts WHERE account_id_plaid = $1", transaction.AccountID).Scan(&accountID)
		if err != nil {
			fmt.Println("Errored in getting category id: ", transaction.CategoryID)
			http.Error(w, http.StatusText(500)+err.Error(), http.StatusInternalServerError)
			return false
		}

		err = db.QueryRow("INSERT INTO transactions (ITEM_ID, ACCOUNT_ID, CATEGORY_ID, BUDGET_NAME, TRANSACTION_ID_PLAID, TRANSACTION_NAME, TRANSACTION_AMOUNT, TRANSACTION_DATE) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id",
			itemID, accountID, categoryID, budgetName, transaction.ID, transaction.Name, transaction.Amount, transaction.Date).Scan(&transactionID)
		if err != nil {
			fmt.Println("Errored: inserting into transaction", transaction.CategoryID)
			http.Error(w, http.StatusText(500)+err.Error(), http.StatusInternalServerError)
			return false
		}
	}

	if len(response.Transactions) < 500 {
		// No more transactions left.
		return false
	}
	// More transactions left, must paginate.
	return true

}

// Get all transactions
func getTransactions(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	itemID := params["item_id"]
	rows, err := db.Query("SELECT * FROM transactions WHERE item_id = $1", itemID)
	if err != nil {
		http.Error(w, http.StatusText(500)+err.Error(), 500)
		return
	}
	defer rows.Close()
	transactions := make([]Transaction, 0)
	for rows.Next() {
		transaction := Transaction{}
		err := rows.Scan(&transaction.ID, &transaction.ItemID, &transaction.AccountID, &transaction.CategoryID, &transaction.BudgetName, &transaction.TransactionIDPlaid, &transaction.Name, &transaction.Amount, &transaction.Date) // order matters
		if err != nil {
			http.Error(w, http.StatusText(500)+err.Error(), 500)
			return
		}
		transactions = append(transactions, transaction)
	}
	if err = rows.Err(); err != nil {
		http.Error(w, http.StatusText(500)+err.Error(), 500)
		return
	}
	fmt.Println("Get all transactions for item id ", itemID)
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(transactions); err != nil {
		panic(err)
	}
}

// Update transaction
func updateTransaction(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	itemID := params["item_id"]
	transactionID := params["transaction_id"]
	if itemID == "" && transactionID == "" {
		http.Error(w, http.StatusText(400), http.StatusBadRequest)
		return
	}
	transaction := Transaction{}
	_ = json.NewDecoder(r.Body).Decode(&transaction)

	// validate new values
	if transaction.Name == "" || transaction.Date == "" {
		http.Error(w, http.StatusText(400), http.StatusBadRequest)
		return
	}

	// insert values
	_, err = db.Exec("UPDATE transactions SET category_id=$3, budget_name=$4, transaction_name=$5, transaction_amount=$6, transaction_date=$7 WHERE item_id=$1 AND id=$2;",
		itemID, transactionID, &transaction.CategoryID, &transaction.BudgetName, &transaction.Name, &transaction.Amount, &transaction.Date)
	if err != nil {
		http.Error(w, http.StatusText(500), http.StatusInternalServerError)
		return
	}

	fmt.Println("Update transaction with id: ", transactionID)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(transaction); err != nil {
		panic(err)
	}
}

// Delete transactions
func deleteTransactions(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	itemID := params["item_id"]
	if itemID == "" {
		http.Error(w, http.StatusText(400)+" Bad inputs", http.StatusBadRequest)
		return
	}

	_, err := db.Exec("DELETE FROM transactions WHERE item_id=$1", itemID)
	if err != nil {
		http.Error(w, http.StatusText(500)+err.Error(), http.StatusInternalServerError)
		return
	}

	fmt.Println("Delete transactions with item id: ", itemID)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
}

// Get all categories
func getCategories(w http.ResponseWriter, r *http.Request) {
	rows, err := db.Query("SELECT * FROM categories")
	if err != nil {
		http.Error(w, http.StatusText(500)+err.Error(), 500)
		return
	}
	defer rows.Close()
	categories := make([]Category, 0)
	for rows.Next() {
		category := Category{}
		err := rows.Scan(&category.ID, &category.CategoryIDPlaid, &category.Group, &category.Category1, &category.Category2, &category.Category3) // order matters
		if err != nil {
			http.Error(w, http.StatusText(500)+err.Error(), 500)
			return
		}
		categories = append(categories, category)
	}
	if err = rows.Err(); err != nil {
		http.Error(w, http.StatusText(500)+err.Error(), 500)
		return
	}
	fmt.Println("Get all categories")
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(categories); err != nil {
		panic(err)
	}
}

// Create for categories
func createCategories(w http.ResponseWriter, r *http.Request) {

	response, err := client.GetCategories()
	if err != nil {
		http.Error(w, http.StatusText(400)+err.Error(), http.StatusBadRequest)
		return
	}

	// insert values
	for i := 0; i < len(response.Categories); i++ {
		category := response.Categories[i]

		cat1 := ""
		cat2 := ""
		cat3 := ""
		catLength := len(category.Hierarchy)
		if catLength == 1 {
			cat1 = category.Hierarchy[0]
		} else if catLength == 2 {
			cat1 = category.Hierarchy[0]
			cat2 = category.Hierarchy[1]
		} else if catLength == 3 {
			cat1 = category.Hierarchy[0]
			cat2 = category.Hierarchy[1]
			cat3 = category.Hierarchy[2]
		}

		_, err := db.Exec("INSERT INTO categories (CATEGORY_ID_PLAID, CATEGORY_GROUP, CATEGORY1, CATEGORY2, CATEGORY3) VALUES ($1, $2, $3, $4, $5)",
			category.CategoryID, category.Group, cat1, cat2, cat3)
		if err != nil {
			http.Error(w, http.StatusText(500)+err.Error(), http.StatusInternalServerError)
			return
		}
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
}

// Retrieve webhook
func receiveWebhook(w http.ResponseWriter, r *http.Request) {
	var webhook Webhook
	_ = json.NewDecoder(r.Body).Decode(&webhook)
	fmt.Println(webhook.WebhookType)
	fmt.Println(webhook.WebhookCode)
	fmt.Println(webhook.ItemIDPlaid)
	if webhook.WebhookCode == "HISTORICAL_UPDATE" {
		// Get all transactions ever.
		createTransactionsInitialMethod(w, r, webhook.ItemIDPlaid)
	} else if webhook.WebhookCode == "DEFAULT_UPDATE" {
		// Get all transactions from the past 10 days.
		createTransactionsUpdate(w, r, webhook.ItemIDPlaid)
	}
}

func getBudgets(w http.ResponseWriter, r *http.Request) []Budget {
	rows, err := db.Query("SELECT * FROM budgets;")
	if err != nil {
		http.Error(w, http.StatusText(500)+err.Error(), 500)
		return nil
	}
	defer rows.Close()
	budgets := make([]Budget, 0)
	for rows.Next() {
		budget := Budget{}
		err := rows.Scan(&budget.ID, &budget.BudgetCategory, &budget.CategoryIDPlaid, &budget.Name)
		if err != nil {
			http.Error(w, http.StatusText(500)+err.Error(), 500)
			return nil
		}
		budgets = append(budgets, budget)
	}
	if err = rows.Err(); err != nil {
		http.Error(w, http.StatusText(500)+err.Error(), 500)
		return nil
	}
	return budgets
}

func getBudgetsCondensed(w http.ResponseWriter, r *http.Request) {
	rows, err := db.Query("SELECT DISTINCT on (name) * FROM budgets;")
	if err != nil {
		http.Error(w, http.StatusText(500)+err.Error(), 500)
		return
	}
	defer rows.Close()
	budgets := make([]Budget, 0)
	for rows.Next() {
		budget := Budget{}
		err := rows.Scan(&budget.ID, &budget.BudgetCategory, &budget.CategoryIDPlaid, &budget.Name)
		if err != nil {
			http.Error(w, http.StatusText(500)+err.Error(), 500)
			return
		}
		budgets = append(budgets, budget)
	}
	if err = rows.Err(); err != nil {
		http.Error(w, http.StatusText(500)+err.Error(), 500)
		return
	}

	fmt.Println("Get all budgets")
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(w).Encode(budgets); err != nil {
		panic(err)
	}
}

// Main function
func main() {
	// Init router
	r := mux.NewRouter()

	// Route handles & endpoints

	// Webhooks
	r.HandleFunc("/", receiveWebhook).Methods("POST")

	// USERS
	r.HandleFunc("/users", createUser).Methods("POST")
	r.HandleFunc("/users/{user_id}", getUser).Methods("GET")
	r.HandleFunc("/users/{user_id}", updateUser).Methods("PUT")
	r.HandleFunc("/users/{user_id}", deleteUser).Methods("DELETE")

	// ITEMS
	r.HandleFunc("/items/{user_id}/{public_token}/{institution_id_plaid}/{account_name}/{account_mask}/{account_subtype}", createItem).Methods("POST")
	r.HandleFunc("/items/{user_id}", getItems).Methods("GET")
	r.HandleFunc("/items/{user_id}/{item_id}", deleteItem).Methods("DELETE")

	// ACCOUNTS
	r.HandleFunc("/accounts/{user_id}/{item_id}/{institution_id_plaid}", createAccounts).Methods("POST")
	r.HandleFunc("/accounts/select_plaid_id/{item_id}/{account_id_plaid}/{show_account}", toggleSelectAccountPlaidID).Methods("PUT")
	r.HandleFunc("/accounts/select_id/{item_id}/{account_id}/{show_account}", toggleSelectAccountID).Methods("PUT")
	r.HandleFunc("/accounts/{item_id}", getAccounts).Methods("GET")
	r.HandleFunc("/accounts/{item_id}/{account_id}", updateAccount).Methods("PUT")
	r.HandleFunc("/accounts/{item_id}/{account_id}", deleteAccount).Methods("DELETE")

	// TRANSACTIONS
	r.HandleFunc("/transactions/{item_id}", createTransactionsInitial).Methods("POST")
	r.HandleFunc("/transactions/{item_id}", getTransactions).Methods("GET")
	r.HandleFunc("/transactions/{item_id}/{transaction_id}", updateTransaction).Methods("PUT")
	r.HandleFunc("/transactions/{item_id}", deleteTransactions).Methods("DELETE")

	// CATEGORIES
	r.HandleFunc("/categories", createCategories).Methods("POST")
	r.HandleFunc("/categories", getCategories).Methods("GET")

	// BUDGETS
	r.HandleFunc("/budgets", getBudgetsCondensed).Methods("GET")

	// PUBLIC TOKEN
	r.HandleFunc("/items/public_token/{item_id}", getPublicToken).Methods("GET")

	// Start server
	log.Fatal(http.ListenAndServe(":8080", r))
}
