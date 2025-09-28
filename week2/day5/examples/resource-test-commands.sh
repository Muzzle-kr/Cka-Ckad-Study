#!/bin/bash

# Day 5: Resource Management & QoS 실습 명령어 모음

echo "=== Day 5: Resource Management & QoS 실습 ==="
echo

# 기본 정보 확인
echo "1. 클러스터 노드 및 리소스 정보 확인"
echo "kubectl get nodes -o wide"
echo "kubectl top nodes"
echo "kubectl describe nodes"
echo

# QoS Classes 실습
echo "2. QoS Classes 실습"
echo "# Guaranteed QoS Pod 생성"
echo "kubectl apply -f guaranteed-pod.yaml"
echo "kubectl describe pod guaranteed-pod | grep -A 5 'QoS Class'"
echo

echo "# Burstable QoS Pod 생성"
echo "kubectl apply -f burstable-pod.yaml"
echo "kubectl describe pod burstable-pod | grep -A 5 'QoS Class'"
echo

echo "# BestEffort QoS Pod 생성"
echo "kubectl apply -f besteffort-pod.yaml"
echo "kubectl describe pod besteffort-pod | grep -A 5 'QoS Class'"
echo

echo "# 모든 Pod의 QoS 클래스 확인"
echo "kubectl get pods -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass"
echo

# 리소스 모니터링
echo "3. 리소스 사용량 모니터링"
echo "kubectl top pods"
echo "kubectl top pods --sort-by=cpu"
echo "kubectl top pods --sort-by=memory"
echo

# Node Selector 실습
echo "4. Node Selector 실습"
echo "# 노드에 레이블 추가"
echo "kubectl label nodes <node-name> disktype=ssd"
echo "kubectl label nodes <node-name> environment=production"
echo

echo "# Node Selector Pod 생성"
echo "kubectl apply -f node-selector-pod.yaml"
echo "kubectl get pod node-selector-pod -o wide"
echo

# Node Affinity 실습
echo "5. Node Affinity 실습"
echo "kubectl apply -f node-affinity-pod.yaml"
echo "kubectl describe pod node-affinity-pod | grep -A 20 'Node-Selectors'"
echo

# Pod Affinity 실습
echo "6. Pod Affinity 실습"
echo "# 먼저 database Pod 생성 (pod-affinity-pod가 참조할 대상)"
echo "kubectl run database --image=postgres:13 --labels=app=database"
echo "kubectl apply -f pod-affinity-pod.yaml"
echo "kubectl get pods -o wide"
echo

# Taint와 Toleration 실습
echo "7. Taint와 Toleration 실습"
echo "# 노드에 taint 추가"
echo "kubectl taint nodes <node-name> special=true:NoSchedule"
echo "kubectl describe node <node-name> | grep Taints"
echo

echo "# Toleration 없는 Pod 테스트"
echo "kubectl apply -f no-toleration-pod.yaml"
echo "kubectl get pods"
echo "kubectl describe pod no-toleration-pod | grep Events -A 10"
echo

echo "# Toleration 있는 Pod 테스트"
echo "kubectl apply -f toleration-pod.yaml"
echo "kubectl get pod toleration-pod -o wide"
echo

# 리소스 부족 시뮬레이션
echo "8. 리소스 부족 상황 시뮬레이션"
echo "kubectl apply -f resource-intensive-pod.yaml"
echo "kubectl get pods"
echo "kubectl describe pod resource-intensive-pod | grep Events -A 10"
echo

# Multi-container Pod 실습
echo "9. Multi-container Pod 실습"
echo "kubectl apply -f multi-container-pod.yaml"
echo "kubectl get pod multi-container-pod"
echo "kubectl describe pod multi-container-pod"
echo "kubectl logs multi-container-pod -c main-app"
echo "kubectl logs multi-container-pod -c log-collector"
echo

# Batch Job 실습
echo "10. Batch Job 실습"
echo "kubectl apply -f batch-job.yaml"
echo "kubectl get jobs"
echo "kubectl get pods -l app=batch-processor"
echo "kubectl logs -l app=batch-processor"
echo

# 정리
echo "11. 리소스 정리"
echo "kubectl delete pod guaranteed-pod burstable-pod besteffort-pod"
echo "kubectl delete pod node-selector-pod node-affinity-pod pod-affinity-pod"
echo "kubectl delete pod no-toleration-pod toleration-pod multi-container-pod"
echo "kubectl delete pod database"
echo "kubectl delete job batch-processing-job"
echo

echo "# 노드 레이블 및 taint 정리"
echo "kubectl label nodes <node-name> disktype-"
echo "kubectl label nodes <node-name> environment-"
echo "kubectl taint nodes <node-name> special=true:NoSchedule-"
echo

echo "=== 실습 완료 ==="