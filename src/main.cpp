#include <iostream>

#include <bsoncxx/json.hpp>

#include <mongocxx/client.hpp>
#include <mongocxx/instance.hpp>
#include "mongocxx/logger.hpp"
#include <bsoncxx/stdx/make_unique.hpp>
#include <bsoncxx/builder/stream/document.hpp>
#include "config.h"

// Copied from
// https://github.com/mongodb/mongo-cxx-driver/blob/master/examples/mongocxx/index.cpp
namespace {
    class logger final : public mongocxx::logger {

    public:
        explicit logger(std::ostream* stream) : _stream(stream) {}

        void operator()(mongocxx::log_level level,
                        bsoncxx::stdx::string_view domain,
                        bsoncxx::stdx::string_view message) noexcept override {
            if (level >= mongocxx::log_level::k_trace)
                return;
            *_stream << '[' << mongocxx::to_string(level) << '@' << domain << "] " << message << '\n';
        }

    private:
        std::ostream* const _stream;
    };
}

int main(int, char**) {
    mongocxx::instance inst{bsoncxx::stdx::make_unique<logger>(&std::cout)};
    try {
        auto client = mongocxx::client{mongocxx::uri{CONNECTION_URI_STR}};

        bsoncxx::builder::stream::document document{};

        auto collection = client["testdb"]["testcollection"];
        document << "hello" << "world";

        collection.insert_one(document.view());
        auto cursor = collection.find({});

        for (auto&& doc : cursor) {
            std::cout << bsoncxx::to_json(doc) << std::endl;
        }
    } catch (const std::exception& xcp) {
        std::cout << "connection failed: " << xcp.what() << "\n";
        return EXIT_FAILURE;
    }
}