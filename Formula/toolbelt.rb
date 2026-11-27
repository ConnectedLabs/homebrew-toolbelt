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
  version "0.1.7"
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/ConnectedLabs/toolbelt/releases/download/toolbelt-v0.1.7/toolbelt-0.1.7-darwin-arm64.tar.gz"
      sha256 "3ae01b874be701d14c03cd984b287ff86d370692db76dcdb8e098ef62b98c43f"
    else
      url "https://github.com/ConnectedLabs/toolbelt/releases/download/toolbelt-v0.1.7/toolbelt-0.1.7-darwin-amd64.tar.gz"
      sha256 "44fa4e02f6326a2c0134b8c3020c8f897af0a2b81a4fd2afbb9725e0e5a91bff"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/ConnectedLabs/toolbelt/releases/download/toolbelt-v0.1.7/toolbelt-0.1.7-linux-arm64.tar.gz"
      sha256 "5aec2cf514000528e193113b268c693329b01856bb6d2f3ec38cb3ae1d459924"
    else
      url "https://github.com/ConnectedLabs/toolbelt/releases/download/toolbelt-v0.1.7/toolbelt-0.1.7-linux-amd64.tar.gz"
      sha256 "3bac8d45b6399ffc848944056e68d997f78663b50413c6ddf7289e24bbd2b476"
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
        "setup_access_probe": "ConnectedLabs/toolbelt/setup-access-probe@607277e34e929a99affde71ebefb770dfafb4f0c # toolbelt-v0.1.7"
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
