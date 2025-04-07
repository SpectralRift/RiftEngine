#include <memory>

#include <Engine/Core/Platform.hpp>
#include <Engine/Runtime/Logger.hpp>
#include <Engine/Input/InputManager.hpp>
#include <Engine/Input/InputModule.hpp>

using namespace engine;

runtime::Logger g_LoggerEngineMain("EngineMain");

// ToDo: implement hooks for engine shutdown
extern void EnginePreShutdown();

// implement this function in your app's main
extern std::shared_ptr<core::runtime::App> CreateApp(core::runtime::AppHost* host);

int EngineMain(int argc, char *argv[]) {
    int returnCode = 0;

    g_LoggerEngineMain.Log(runtime::LOG_LEVEL_DEBUG, "SR1 Engine running on %s",
                           core::Platform::GetName().c_str());

    // internal module startup
    input::InputModule::ModuleStartup();
//    ConsoleModule::ModuleStartup();

    // engine main loop
    auto appHost = core::Platform::GetSuitableHost();

    if (!appHost) {
        core::Platform::ShowMessageBox(
                "SR1 Engine Error",
                "The engine could not identify a suitable host for the application to run.\n\n"
                "Please check out SpectralRift's documentation for more information."
        );

        returnCode = -1;
    } else if (!appHost->Initialize()) {
        core::Platform::ShowMessageBox(
                "SR1 Engine Error",
                "The engine could not initialize the application host.\n\n"
                "Please check out SpectralRift's documentation for more information."
        );

        returnCode = -1;
    } else {
        // init input manager
        input::InputManager::Instance()->Initialize();
        appHost->Run(CreateApp(appHost.get()));
    }

    g_LoggerEngineMain.Log(runtime::LOG_LEVEL_DEBUG, "SR1 Engine shutting down...");

    EnginePreShutdown();

    // shutdown input manager
    input::InputManager::Instance()->Shutdown();

    appHost->Shutdown();

    // internal module shutdown
//    ConsoleModule::ModuleShutdown();
    input::InputModule::ModuleShutdown();

    g_LoggerEngineMain.Log(runtime::LOG_LEVEL_DEBUG, "SR1 Engine shut down with ret code %i",
                           returnCode);

    return returnCode;
}