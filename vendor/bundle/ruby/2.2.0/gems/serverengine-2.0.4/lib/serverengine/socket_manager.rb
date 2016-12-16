#
# ServerEngine
#
# Copyright (C) 2012-2013 Sadayuki Furuhashi
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
require 'socket'
require 'ipaddr'

module ServerEngine
  module SocketManager

    class Client
      def initialize(path)
        @path = path
      end

      def listen(proto, bind, port)
        bind_ip = IPAddr.new(IPSocket.getaddress(bind))
        family = bind_ip.ipv6? ? Socket::AF_INET6 : Socket::AF_INET

        listen_method = case proto
                        when :tcp then :listen_tcp
                        when :udp then :listen_udp
                        else
                          raise ArgumentError, "unknown protocol: #{proto}"
                        end
        peer = connect_peer(@path)
        begin
          SocketManager.send_peer(peer, [Process.pid, listen_method, bind, port])
          res = SocketManager.recv_peer(peer)
          if res.is_a?(Exception)
            raise res
          else
            return send(:recv, family, proto, peer, res)
          end
        ensure
          peer.close
        end
      end

      def listen_tcp(bind, port)
        listen(:tcp, bind, port)
      end

      def listen_udp(bind, port)
        listen(:udp, bind, port)
      end
    end

    class Server
      def self.generate_path
        if ServerEngine.windows?
          for port in 10000..65535
            if `netstat -na | findstr "#{port}"`.length == 0
              return port
            end
          end
        else
          '/tmp/SERVERENGINE_SOCKETMANAGER_' + Time.now.to_s.gsub(' ', '') + '_' + Process.pid.to_s
        end
      end

      def self.open(path)
        new(path)
      end

      def initialize(path)
        @tcp_sockets = {}
        @udp_sockets = {}
        @mutex = Mutex.new
        @path = start_server(path)
      end

      attr_reader :path

      def new_client
        Client.new(@path)
      end

      def close
        stop_server
        nil
      end

      private

      def listen(proto, bind, port)
        sockets, new_method = case proto
                              when :tcp then [@tcp_sockets, :listen_tcp_new]
                              when :udp then [@udp_sockets, :listen_udp_new]
                              else
                                raise ArgumentError, "invalid protocol: #{proto}"
                              end
        key, bind_ip = resolve_bind_key(bind, port)

        @mutex.synchronize do
          unless sockets.has_key?(key)
            sockets[key] = send(new_method, bind_ip, port)
          end
          return sockets[key]
        end
      end

      def listen_tcp(bind, port)
        listen(:tcp, bind, port)
      end

      def listen_udp(bind, port)
        listen(:udp, bind, port)
      end

      def resolve_bind_key(bind, port)
        bind_ip = IPAddr.new(IPSocket.getaddress(bind))
        if bind_ip.ipv6?
          return "[#{bind_ip}]:#{port}", bind_ip
        else
          # assuming ipv4
          if bind_ip == "127.0.0.1" or bind_ip == "0.0.0.0"
            return "localhost:#{port}", bind_ip
          end
          return "#{bind_ip}:#{port}", bind_ip
        end
      end

      def process_peer(peer)
        while true
          pid, method, bind, port = *SocketManager.recv_peer(peer)
          begin
            send_socket(peer, pid, method, bind, port)
          rescue => e
            SocketManager.send_peer(peer, e)
          end
        end
      ensure
        peer.close
      end
    end

    def self.send_peer(peer, obj)
      data = Marshal.dump(obj)
      peer.write [data.bytesize].pack('N')
      peer.write data
    end

    def self.recv_peer(peer)
      len = peer.read(4).unpack('N').first
      data = peer.read(len)
      Marshal.load(data)
    end

    if ServerEngine.windows?
      require_relative 'socket_manager_win'
      Client.include(SocketManagerWin::ClientModule)
      Server.include(SocketManagerWin::ServerModule)
    else
      require_relative 'socket_manager_unix'
      Client.include(SocketManagerUnix::ClientModule)
      Server.include(SocketManagerUnix::ServerModule)
    end

  end
end
