#pragma once
#include <Poco/Data/Session.h>

namespace db {
Poco::Data::Session& getSession(const std::string& connectionString);
} // namespace db
