PROJECT_KEY := $(shell printf '%s' "$(CURDIR)" | sed 's|[/_]|-|g; s|^-||')

.PHONY: test verify-docs verify-scripts smoke-statusline smoke-health

test: verify-docs verify-scripts smoke-statusline smoke-health

verify-docs:
	for f in skills/*/SKILL.md; do \
		head -5 "$$f" | grep -q "^name:" && echo "ok: $$f" || { echo "MISSING name: $$f"; exit 1; }; \
	done
	for skill in check design drive health hunt learn read think write; do \
		skill_ver=$$(grep -m1 "version:" "skills/$$skill/SKILL.md" | tr -d '"' | awk '{print $$2}'); \
		market_ver=$$(python3 -c "import json; d=json.load(open('.claude-plugin/marketplace.json')); print([p['version'] for p in d['plugins'] if p['name']=='$$skill'][0])"); \
		[ "$$skill_ver" = "$$market_ver" ] && echo "ok: $$skill $$skill_ver" || { echo "MISMATCH: $$skill SKILL=$$skill_ver MARKET=$$market_ver"; exit 1; }; \
	done
	test -f skills/design/references/design-reference.md
	test -f skills/read/references/read-methods.md
	test -f skills/write/references/write-zh.md
	test -f skills/write/references/write-en.md
	test -f skills/health/agents/inspector-context.md
	test -f skills/health/agents/inspector-control.md
	test -f skills/check/agents/reviewer-security.md
	test -f skills/check/agents/reviewer-architecture.md
	test -f skills/check/references/persona-catalog.md
	echo "references: ok"
	python3 -c "import json; json.load(open('.claude-plugin/marketplace.json'))"
	echo "marketplace.json: ok"

verify-scripts:
	git diff --check
	bash -n scripts/statusline.sh skills/health/scripts/collect-data.sh skills/read/scripts/fetch.sh scripts/setup-statusline.sh skills/check/scripts/run-tests.sh
	echo "bash -n: ok"
	python3 -m py_compile skills/read/scripts/fetch_feishu.py skills/read/scripts/fetch_weixin.py
	echo "py_compile: ok"
	bash skills/health/scripts/collect-data.sh auto >/tmp/waza-collect-data.out
	echo "collect-data: ok"
	rg -n "^=== CONVERSATION SIGNALS ===$$|^=== CONVERSATION EXTRACT ===$$|^=== MCP ACCESS DENIALS ===$$" /tmp/waza-collect-data.out

smoke-statusline:
	@tmpdir=$$(mktemp -d); \
	json1='{"context_window":{"current_usage":{"input_tokens":10},"context_window_size":100},"rate_limits":{"five_hour":{"used_percentage":12,"resets_at":2000000000},"seven_day":{"used_percentage":34,"resets_at":2000003600}}}'; \
	json2='{"context_window":{"current_usage":{"input_tokens":20},"context_window_size":100}}'; \
	printf '%s' "$$json1" | HOME="$$tmpdir" bash scripts/statusline.sh >/dev/null; \
	printf '%s' "$$json2" | HOME="$$tmpdir" bash scripts/statusline.sh >"$$tmpdir/out2"; \
	printf '%s' "$$json2" | HOME="$$tmpdir" bash scripts/statusline.sh >"$$tmpdir/out3"; \
	grep -q '"used_percentage": 12' "$$tmpdir/.cache/waza-statusline/last.json"; \
	grep -q '5h:' "$$tmpdir/out2"; \
	grep -q '7d:' "$$tmpdir/out2"; \
	grep -q '12%' "$$tmpdir/out2"; \
	grep -q '34%' "$$tmpdir/out3"; \
	echo "statusline smoke: ok"

smoke-health:
	@tmpdir=$$(mktemp -d); \
	convo_dir="$$tmpdir/.claude/projects/-$(PROJECT_KEY)"; \
	mkdir -p "$$convo_dir"; \
	printf '%s\n' '{"type":"user","message":{"content":"Please build a dashboard for sales data."}}' > "$$convo_dir/2-old.jsonl"; \
	printf '%s\n' '{"type":"user","message":{"content":"Please do not use em dashes next time."}}' >> "$$convo_dir/2-old.jsonl"; \
	printf '%s\n' '{"type":"user","message":{"content":"active session placeholder"}}' > "$$convo_dir/1-active.jsonl"; \
	HOME="$$tmpdir" bash skills/health/scripts/collect-data.sh auto > "$$tmpdir/health.out"; \
	grep -q '^=== CONVERSATION SIGNALS ===$$' "$$tmpdir/health.out"; \
	grep -q '^USER CORRECTION: Please do not use em dashes next time\.$$' "$$tmpdir/health.out"; \
	if grep -q '^USER CORRECTION: Please build a dashboard for sales data\.$$' "$$tmpdir/health.out"; then \
		echo "false positive correction detected"; exit 1; \
	fi; \
	echo "health smoke: ok"
