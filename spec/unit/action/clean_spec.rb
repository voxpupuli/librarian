require "librarian/action/clean"

module Librarian
  describe Action::Clean do

    let(:env) { double }
    let(:action) { described_class.new(env) }

    before do
      allow(action).to receive(:debug)
    end

    describe "#run" do

      describe "behavior" do

        after do
          action.run
        end

        describe "clearing the cache path" do

          before do
            allow(action).to receive(:clean_install_path)
          end

          context "when the cache path is missing" do
            before do
              allow(env).to receive_message_chain(:cache_path, :exist?).and_return(false)
            end

            it "should not try to clear the cache path" do
              expect(env.cache_path).to receive(:rmtree).never
            end
          end

          context "when the cache path is present" do
            before do
              allow(env).to receive_message_chain(:cache_path, :exist?).and_return(true)
            end

            it "should try to clear the cache path" do
              expect(env.cache_path).to receive(:rmtree).exactly(:once)
            end
          end

        end

        describe "clearing the install path" do

          before do
            allow(action).to receive(:clean_cache_path)
          end

          context "when the install path is missing" do
            before do
              allow(env).to receive_message_chain(:install_path, :exist?).and_return(false)
            end

            it "should not try to clear the install path" do
              expect(env.install_path).to receive(:children).never
            end
          end

          context "when the install path is present" do
            before do
              allow(env).to receive_message_chain(:install_path, :exist?).and_return(true)
            end

            it "should try to clear the install path" do
              children = [double, double, double]
              children.each do |child|
                allow(child).to receive(:file?).and_return(false)
              end
              allow(env).to receive_message_chain(:install_path, :children).and_return(children)

              children.each do |child|
                expect(child).to receive(:rmtree).exactly(:once)
              end
            end

            it "should only try to clear out directories from the install path, not files" do
              children = [double(:file? => false), double(:file? => true), double(:file? => true)]
              allow(env).to receive_message_chain(:install_path, :children).and_return(children)

              children.select(&:file?).each do |child|
                expect(child).to receive(:rmtree).never
              end
              children.reject(&:file?).each do |child|
                expect(child).to receive(:rmtree).exactly(:once)
              end
            end
          end

        end

      end

    end

  end
end
