# typed: strict
# frozen_string_literal: true

# Installs toolbelt, ratchet and plumbob at one release version, with the
# installing organization's configuration: its supply endpoint, execution
# provider and declared sets. The archives come from the public releases
# repository; the configuration is only in this tap. The archives are not
# signed: the SHA-256 below verifies their bytes, not who published them.
class Toolbelt < Formula
  desc "Requirements, supply and execution for a component's own build"
  homepage "https://github.com/ConnectedLabs/toolbelt"
  version "0.1.0-rc.2"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ConnectedLabs/toolbelt/releases/download/toolbelt-v0.1.0-rc.2/toolbelt-0.1.0-rc.2-darwin-arm64.tar.gz"
      sha256 "80e3ac571f338211ab60bdef73375d6b152b7a7f8e392848534fb2e5a7dc794f"
    else
      url "https://github.com/ConnectedLabs/toolbelt/releases/download/toolbelt-v0.1.0-rc.2/toolbelt-0.1.0-rc.2-darwin-amd64.tar.gz"
      sha256 "b25734d56e9563cadaacd1c8e385229b239404b233456b6ffa4e4841a6df36b2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/ConnectedLabs/toolbelt/releases/download/toolbelt-v0.1.0-rc.2/toolbelt-0.1.0-rc.2-linux-arm64.tar.gz"
      sha256 "6ef6bb9fc2de0c284ee609b11875872fc9a368a8fbf9f772d2449446842c419c"
    else
      url "https://github.com/ConnectedLabs/toolbelt/releases/download/toolbelt-v0.1.0-rc.2/toolbelt-0.1.0-rc.2-linux-amd64.tar.gz"
      sha256 "e0e69f84a3fbf522fd97acf8a90b38b8c92be5c0e1cb8ae808f8215ad10d962a"
    end
  end

  def install
    bin.install "toolbelt", "ratchet", "plumbob"
    pkgshare.install "PROVENANCE.json"
    (pkgshare/"config.json").write <<~JSON
      {
        "endpoint": "https://artifacts.pong.ai/repository/raw-dev/build-supply/",
        "provider_repository": "ConnectedLabs/internal-sdlc-tooling",
        "provider_ref": "feat/toolbelt",
        "operator": "ConnectedLabs",
        "setup_access_probe": "ConnectedLabs/toolbelt/setup-access-probe@0b7a8093e6b5c513fdbaeb3dc02a442ad896d4c0 # toolbelt-v0.1.0-rc.2"
      }
    JSON
    (pkgshare/"sets").mkpath
    (pkgshare/"sets/pong.yaml").write <<~YAML
      # set.v1: the repositories that work together in the Pong project.
      # Members are named by repository; toolbelt survey --set finds local clones
      # by their remote (--checkouts), never by path.
      contract: set.v1
      name: pong
      owner: ConnectedLabs
      members:
        # The application monorepo
        - ConnectedLabs/pong_legacy
        # Platform operations: runtime images, infrastructure, delivery
        - sovnedge/se-platform-ops
        - sovnedge/se-platform-services
        - sovnedge/se-platform-surfaces
        - sovnedge/sovnctl
        # SDLC tooling: toolbelt and its compilation, CI platform
        - ConnectedLabs/internal-sdlc-tooling
        - ConnectedLabs/ci-platform-core
        # PongLabs originals still outside pong_legacy
        - PongLabs/ponglabs_broker
        - PongLabs/PongWebsite
        - PongLabs/ponglabs-openai_gw
        - PongLabs/pong_svc_orca
        - PongLabs/structured-communication-platform
        - PongLabs/pong-product-web-client
        # Runtime platforms
        - ConnectedLabs/sovn-run-platform
        - ConnectedLabs/network-runtime
        - ConnectedLabs/tailmesh-platform
    YAML
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/toolbelt version").strip
    assert_equal version.to_s, shell_output("#{bin}/ratchet version").strip
    assert_equal version.to_s, shell_output("#{bin}/plumbob version").strip
    assert_match "usage: toolbelt run", shell_output("#{bin}/toolbelt run --help 2>&1")
  end
end
