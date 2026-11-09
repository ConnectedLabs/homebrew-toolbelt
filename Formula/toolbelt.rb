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
  version "0.1.1"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ConnectedLabs/toolbelt/releases/download/toolbelt-v0.1.1/toolbelt-0.1.1-darwin-arm64.tar.gz"
      sha256 "6bfc90a21ff20b3c89269aa21487fae7c9199c6e0d8ed17afc0e78e0b4a98280"
    else
      url "https://github.com/ConnectedLabs/toolbelt/releases/download/toolbelt-v0.1.1/toolbelt-0.1.1-darwin-amd64.tar.gz"
      sha256 "20f2167bcce168918434aea71f1fc619b4ba66a5c70c3d7173c4ff3bd4022fab"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/ConnectedLabs/toolbelt/releases/download/toolbelt-v0.1.1/toolbelt-0.1.1-linux-arm64.tar.gz"
      sha256 "25c983f75dce17d253a8e1e3df96a255f46ad0618cd385a9dd49f6f9a33ea509"
    else
      url "https://github.com/ConnectedLabs/toolbelt/releases/download/toolbelt-v0.1.1/toolbelt-0.1.1-linux-amd64.tar.gz"
      sha256 "786b2afb5bfbcc80134d794c35c5d1666d58c89ecd535d9db7df3f11b71c02d2"
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
        "setup_access_probe": "ConnectedLabs/toolbelt/setup-access-probe@19fbab8380bd9452ea2eb5355378d1c72f191107 # toolbelt-v0.1.1"
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
