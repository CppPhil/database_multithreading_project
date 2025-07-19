#include <mutex>
#include <stdexcept>
#include <string>

#include <gsl/util>

#include <Poco/Data/MySQL/Connector.h>
#include <Poco/Data/SessionFactory.h>

namespace db {
namespace {
Poco::Data::Session createSession(const std::string& connectionString)
{
  Poco::Data::SessionFactory& sessionFactory{
    Poco::Data::SessionFactory::instance()};
  Poco::Data::Session session{
    sessionFactory.create(Poco::Data::MySQL::Connector::KEY, connectionString)};
  return session;
}
} // anonymous namespace

Poco::Data::Session& getSession(const std::string& connectionString)
{
  static std::once_flag onceFlag{};
  std::call_once(
    onceFlag, [] { Poco::Data::MySQL::Connector::registerConnector(); });
  thread_local Poco::Data::Session session{createSession(connectionString)};

  if (!session.isConnected()) {
    throw std::runtime_error{"Session is not connected!"};
  }

  if (!session.isGood()) {
    throw std::runtime_error{"Session is bad!"};
  }

  thread_local auto scopeGuard{gsl::finally([] { session.close(); })};
  return session;
}
} // namespace db
