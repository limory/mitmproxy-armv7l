FROM python AS build

ARG TAG=latest
RUN --privileged mkdir -p /tmp/cargo && \
    mount -t tmpfs -o size=1G tmpfs /tmp/cargo && \
    export CARGO_HOME=/tmp/cargo
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && source $HOME/.cargo/env && \
	pip wheel --wheel-dir=/wheels mitmproxy$([[ ${TAG} != "latest" ]] && echo "==${TAG}" || echo "") && \
    	find /root/.cache/pip/wheels -type f -name "*.whl" -exec cp {} /wheels \;&& \
	pip --no-cache-dir install --no-index --find-links=/wheels mitmproxy && \
	pip install pyinstaller && \
	cd /root/.mitmproxy && \
	pyinstaller -F $(which mitmdump) && \
	pyinstaller -F $(which mitmweb) && \
	pyinstaller -F $(which mitmproxy)
 
CMD [ "bash" ]

#FROM debian:stable-slim
#COPY --from=build /root/.mitmproxy /root
#RUN chmod +x /root/.mitmproxy/dist/* && mv /root/.mitmproxy/dist/* /usr/bin && \
#    rm -rf /root/.mitmproxy/dist
    
#VOLUME /root/.mitmproxy
#EXPOSE 8080 8081
#CMD [ "mitmproxy" ]
