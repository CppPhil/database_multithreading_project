#include "get_session.hpp"
#include <Poco/Data/MySQL/Connector.h>
#include <Poco/Data/Session.h>
#include <Poco/Data/Statement.h>
#include <iostream>
#include <random>
#include <string>
#include <thread>

using namespace Poco::Data::Keywords;

std::string randomString(int length)
{
  static const std::string chars
    = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
  static std::random_device       rd;
  static std::mt19937             gen(rd());
  std::uniform_int_distribution<> dis(0, chars.size() - 1);
  std::string                     result;
  result.reserve(length);
  for (int i = 0; i < length; ++i) {
    result += chars[dis(gen)];
  }
  return result;
}

int main()
{
  std::string connStr = "host=localhost;user=root;password=letmein;db=company";

  std::string firstName1      = randomString(5);
  std::string lastName1       = randomString(7);
  std::string email1          = randomString(5) + "@example.com";
  std::string firstName2      = randomString(6);
  std::string lastName2       = randomString(8);
  std::string email2          = randomString(6) + "@example.com";
  std::string emailUpdate     = randomString(5) + "@example.com";
  std::string firstNameUpdate = randomString(5);

  std::jthread t1([connStr, firstName1, lastName1, email1]() {
    try {
      auto&                 session = db::getSession(connStr);
      Poco::Data::Statement insert(session);
      insert << "INSERT INTO employee (first_name, last_name, email) VALUES "
                "(?, ?, ?)",
        useRef(firstName1), useRef(lastName1), useRef(email1);
      insert.execute();
      std::cout << "Inserted: " << firstName1 << " " << lastName1 << "\n";
    }
    catch (const Poco::Exception& e) {
      std::cerr << "Error: " << e.displayText() << "\n";
    }
  });

  std::jthread t2([connStr, firstName2, lastName2, email2]() {
    try {
      auto&                 session = db::getSession(connStr);
      Poco::Data::Statement insert(session);
      insert << "INSERT INTO employee (first_name, last_name, email) VALUES "
                "(?, ?, ?)",
        useRef(firstName2), useRef(lastName2), useRef(email2);
      insert.execute();
      std::cout << "Inserted: " << firstName2 << " " << lastName2 << "\n";
    }
    catch (const Poco::Exception& e) {
      std::cerr << "Error: " << e.displayText() << "\n";
    }
  });

  std::jthread t3([connStr]() {
    try {
      auto&                 session = db::getSession(connStr);
      Poco::Data::Statement select(session);
      select << "SELECT * FROM employee";
      select.execute();
      std::cout << "Executed: SELECT * FROM employee\n";
    }
    catch (const Poco::Exception& e) {
      std::cerr << "Error: " << e.displayText() << "\n";
    }
  });

  std::jthread t4([connStr, emailUpdate, firstNameUpdate]() {
    try {
      auto&                 session = db::getSession(connStr);
      Poco::Data::Statement update(session);
      update << "UPDATE employee SET email = ? WHERE first_name = ?",
        useRef(emailUpdate), useRef(firstNameUpdate);
      update.execute();
      std::cout << "Updated email for: " << firstNameUpdate << "\n";
    }
    catch (const Poco::Exception& e) {
      std::cerr << "Error: " << e.displayText() << "\n";
    }
  });
}