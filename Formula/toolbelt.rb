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
  version "0.1.6"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ConnectedLabs/toolbelt/releases/download/toolbelt-v0.1.6/toolbelt-0.1.6-darwin-arm64.tar.gz"
      sha256 "4720f337bbaba721fc1b681d045d61b5f56d13754ff751c40a9b335543eaac16"
    else
      url "https://github.com/ConnectedLabs/toolbelt/releases/download/toolbelt-v0.1.6/toolbelt-0.1.6-darwin-amd64.tar.gz"
      sha256 "8a93e7c8c7536978c4b06d2bd335c1c737338c6bd62e5159c8fadf7530f6e4a5"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/ConnectedLabs/toolbelt/releases/download/toolbelt-v0.1.6/toolbelt-0.1.6-linux-arm64.tar.gz"
      sha256 "634b6dfa6e72c4f949e6946f3de545001c971c3406844d6685e23e53c7d2a41c"
    else
      url "https://github.com/ConnectedLabs/toolbelt/releases/download/toolbelt-v0.1.6/toolbelt-0.1.6-linux-amd64.tar.gz"
      sha256 "8022c50874c8368abcf85ef7f78b771b09194cf70a2eba4cb5766439ec02b9d1"
    end
  end

  def install
    bin.install "toolbelt", "ratchet", "plumbob"
    pkgshare.install "PROVENANCE.json"
    (pkgshare/"config.json").write <<~JSON
      {
        "endpoint": "https://artifacts.pong.ai/repository/raw-dev/build-supply/",
        "provider_repository": "ConnectedLabs/internal-sdlc-tooling",
        "provider_ref": "main",
        "operator": "ConnectedLabs",
        "setup_access_probe": "ConnectedLabs/toolbelt/setup-access-probe@06358b4e5881154fb549a66ca2e772bfea595690 # toolbelt-v0.1.6"
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
